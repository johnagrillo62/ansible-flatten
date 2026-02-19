(playbook "debops/ansible/roles/gitlab_runner/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Create required groups"
      (ansible.builtin.group 
        (name (jinja "{{ item.name if item.name | d() else item }}"))
        (system (jinja "{{ item.system | bool if item.system is defined else gitlab_runner__system | bool }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", [gitlab_runner__group]
                           + gitlab_runner__additional_groups) }}")))
    (task "Create gitlab-runner user"
      (ansible.builtin.user 
        (name (jinja "{{ gitlab_runner__user }}"))
        (group (jinja "{{ gitlab_runner__group }}"))
        (groups (jinja "{{ gitlab_runner__additional_groups | map(attribute=\"name\") | list | join(\",\") }}"))
        (append "True")
        (home (jinja "{{ gitlab_runner__home }}"))
        (system (jinja "{{ gitlab_runner__system | bool }}"))
        (comment (jinja "{{ gitlab_runner__comment }}"))
        (shell (jinja "{{ gitlab_runner__shell }}"))
        (state "present")
        (generate_ssh_key (jinja "{{ gitlab_runner__ssh_generate | bool }}"))
        (ssh_key_bits (jinja "{{ gitlab_runner__ssh_generate_bits }}"))
        (skeleton null)))
    (task "Remove '~/.bash_logout' to avoid conflicts with the shell runner"
      (ansible.builtin.file 
        (state "absent")
        (path (jinja "{{ gitlab_runner__home }}") "/.bash_logout")))
    (task "Allow Docker access for gitlab-runner user"
      (ansible.builtin.user 
        (name (jinja "{{ gitlab_runner__user }}"))
        (groups "docker")
        (append "True"))
      (when "(ansible_local | d() and ansible_local.docker_server | d() and (ansible_local.docker_server.installed | d()) | bool)"))
    (task "Copy custom files to GitLab Runner host"
      (ansible.builtin.copy 
        (src (jinja "{{ item.src | d(omit) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (dest (jinja "{{ item.dest }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (directory_mode (jinja "{{ item.directory_mode | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", gitlab_runner__custom_files
                           + gitlab_runner__group_custom_files
                           + gitlab_runner__host_custom_files) }}"))
      (when "((item.src | d() or item.content | d()) and item.dest | d())"))
    (task "Make sure APT can access HTTPS repositories"
      (ansible.builtin.apt 
        (name (list
            "apt-transport-https"
            "openssl"
            "ca-certificates"))
        (state "present")
        (install_recommends "False")
        (update_cache "True")
        (cache_valid_time (jinja "{{ ansible_local.core.cache_valid_time | d(\"86400\") }}")))
      (register "gitlab_runner__register_apt_https")
      (until "gitlab_runner__register_apt_https is succeeded"))
    (task "Install gitlab-runner packages"
      (ansible.builtin.apt 
        (name (jinja "{{ query('flattened', gitlab_runner__base_packages +
                                 gitlab_runner__packages) }}"))
        (state "present")
        (install_recommends "False"))
      (register "gitlab_runner__register_packages")
      (until "gitlab_runner__register_packages is succeeded"))
    (task "Register new GitLab Runners"
      (ansible.builtin.uri 
        (url (jinja "{{ (item.api_url | d(gitlab_runner__api_url)) + \"api/v4/user/runners\" }}"))
        (method "POST")
        (headers 
          (PRIVATE-TOKEN (jinja "{{ item.api_token | d(gitlab_runner__api_token) }}")))
        (body_format "form-urlencoded")
        (body 
          (runner_type (jinja "{{ item.runner_type | d(gitlab_runner__runner_type) }}"))
          (group_id (jinja "{{ item.group_id | d(gitlab_runner__group_id) | d(omit) }}"))
          (project_id (jinja "{{ item.project_id | d(gitlab_runner__project_id) | d(omit) }}"))
          (description (jinja "{{ item.name }}"))
          (tag_list (jinja "{{ (item.tags | d([])
                     + (gitlab_runner__shell_tags
                        if (item.executor == \"shell\") else [])
                     + gitlab_runner__combined_tags)
                     | unique | join(\",\") }}"))
          (run_untagged (jinja "{{ item.run_untagged | d(gitlab_runner__run_untagged) }}"))
          (paused (jinja "{{ item.paused | d(omit) }}"))
          (locked (jinja "{{ item.locked | d(omit) }}"))
          (access_level (jinja "{{ item.access_level | d(omit) }}"))
          (maximum_timeout (jinja "{{ item.maximum_timeout | d(omit) }}"))
          (maintenance_note (jinja "{{ item.maintenance_note | d(omit) }}")))
        (status_code "200,201"))
      (register "gitlab_runner__register_new_instances")
      (loop (jinja "{{ q(\"flattened\", gitlab_runner__default_instances
                           + gitlab_runner__instances
                           + gitlab_runner__group_instances
                           + gitlab_runner__host_instances) }}"))
      (when "((item.api_token | d() or gitlab_runner__api_token) and item.name and (item.state is undefined or item.state != 'absent') and (ansible_local is undefined or (ansible_local | d() and (ansible_local.gitlab_runner is undefined or (ansible_local.gitlab_runner | d() and ansible_local.gitlab_runner.instances is defined and item.name not in ansible_local.gitlab_runner.instances)))))"))
    (task "Generate GitLab Runner configuration files"
      (ansible.builtin.template 
        (src "etc/gitlab-runner/" (jinja "{{ item }}") ".j2")
        (dest "/etc/gitlab-runner/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0600"))
      (with_items (list
          "config.toml"
          "ansible.json")))
    (task "Delete GitLab Runners if requested"
      (ansible.builtin.uri 
        (url (jinja "{{ (item.0.api_url | d(gitlab_runner__api_url)) + \"api/v4/runners/\" + item.1.id | string }}"))
        (method "DELETE")
        (headers 
          (PRIVATE-TOKEN (jinja "{{ item.0.api_token | d(gitlab_runner__api_token) }}"))))
      (with_together (list
          (jinja "{{ gitlab_runner__default_instances + gitlab_runner__instances
          + gitlab_runner__group_instances + gitlab_runner__host_instances }}")
          (jinja "{{ ansible_local.gitlab_runner.instance_tokens | d([]) }}")))
      (when "((item.0.api_token | d() or gitlab_runner__api_token) and item.0.name | d() and item.1.name | d() and item.0.name == item.1.name and (item.0.state | d() and item.0.state == 'absent'))")
      (failed_when "False")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Get the SSH key from the remote host"
      (ansible.builtin.slurp 
        (src "~" (jinja "{{ gitlab_runner__user }}") "/.ssh/id_rsa.pub"))
      (register "gitlab_runner__register_ssh_key")
      (when "gitlab_runner__ssh_generate | bool"))
    (task "Distribute SSH key to other hosts"
      (ansible.posix.authorized_key 
        (key (jinja "{{ gitlab_runner__register_ssh_key.content | b64decode | trim }}"))
        (user (jinja "{{ item.user }}"))
        (state "present")
        (key_options (jinja "{{ item.options | d() }}")))
      (delegate_to (jinja "{{ item.host }}"))
      (become (jinja "{{ item.become | d(True) }}"))
      (with_items (jinja "{{ gitlab_runner__ssh_install_to }}"))
      (when "gitlab_runner__ssh_generate | bool and item.user | d() and item.host | d()"))
    (task "Make sure that the ~/.ssh directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ gitlab_runner__home }}") "/.ssh")
        (state "directory")
        (owner (jinja "{{ gitlab_runner__user }}"))
        (group (jinja "{{ gitlab_runner__group }}"))
        (mode "0700"))
      (when "gitlab_runner__ssh_known_hosts | d()"))
    (task "Make sure the ~/.ssh/known_hosts file exists"
      (ansible.builtin.copy 
        (content "")
        (dest (jinja "{{ gitlab_runner__home }}") "/.ssh/known_hosts")
        (owner (jinja "{{ gitlab_runner__user }}"))
        (group (jinja "{{ gitlab_runner__group }}"))
        (mode "0644")
        (force "False"))
      (when "gitlab_runner__ssh_known_hosts | d()"))
    (task "Get list of already scanned host fingerprints"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && ssh-keygen -f " (jinja "{{ gitlab_runner__home }}") "/.ssh/known_hosts -F " (jinja "{{ item }}") " | grep -q '^# Host " (jinja "{{ item }}") " found'")
      (args 
        (executable "bash"))
      (with_items (jinja "{{ gitlab_runner__ssh_known_hosts }}"))
      (when "gitlab_runner__ssh_known_hosts | d()")
      (register "gitlab_runner__register_known_hosts")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False"))
    (task "Scan SSH fingerprints of specified hosts"
      (ansible.builtin.shell "ssh-keyscan -H -T 10 " (jinja "{{ item.item }}") " >> " (jinja "{{ gitlab_runner__home + \"/.ssh/known_hosts\" }}"))
      (with_items (jinja "{{ gitlab_runner__register_known_hosts.results }}"))
      (register "gitlab_runner__register_keyscan")
      (changed_when "gitlab_runner__register_keyscan.changed | bool")
      (when "gitlab_runner__ssh_known_hosts and item is defined and item.rc > 0")
      (failed_when "False"))
    (task "Configure Vagrant libvirt access"
      (ansible.builtin.user 
        (name (jinja "{{ gitlab_runner__user }}"))
        (append "True")
        (groups (jinja "{{ ([ansible_local.libvirtd.unix_sock_group
                  if (ansible_local.libvirtd.unix_sock_group | d())
                  else \"libvirt\"]
                 + ([\"kvm\"]
                    if (ansible_local | d() and ansible_local.libvirtd | d() and
                        (ansible_local.libvirtd.hw_virt | d()) | bool)
                    else [])) | join(\",\") }}")))
      (when "gitlab_runner__vagrant_libvirt | bool"))
    (task "Configure Vagrant libvirt sudo access"
      (ansible.builtin.template 
        (src "etc/sudoers.d/gitlab-runner-vagrant-libvirt.j2")
        (dest "/etc/sudoers.d/gitlab-runner-vagrant-libvirt")
        (owner "root")
        (group "root")
        (mode "0440"))
      (when "(ansible_local | d() and ansible_local.sudo | d() and (ansible_local.sudo.installed | d()) | bool and gitlab_runner__vagrant_libvirt | bool)"))
    (task "Find 'vagrant-libvirt' source code"
      (ansible.builtin.command "find /usr/share/rubygems-integration/all/gems -maxdepth 1 -type d -name 'vagrant-libvirt-*'")
      (register "gitlab_runner__register_libvirt_source")
      (when "gitlab_runner__vagrant_libvirt_patch | bool")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::gitlab_runner:patch")))
    (task "Patch 'vagrant-libvirt' source code"
      (ansible.posix.patch 
        (src (jinja "{{ \"patches/package_domain-keep-ssh-host-keys-\"
             + (item | basename | replace(\"vagrant-libvirt-\", \"\")) + \".patch\" }}"))
        (basedir (jinja "{{ item }}"))
        (state (jinja "{{ gitlab_runner__vagrant_libvirt_patch_state }}")))
      (with_items (jinja "{{ gitlab_runner__register_libvirt_source.stdout_lines }}"))
      (when "gitlab_runner__vagrant_libvirt_patch | bool")
      (tags (list
          "role::gitlab_runner:patch")))
    (task "Configure Vagrant LXC sudo access"
      (ansible.builtin.template 
        (src "etc/sudoers.d/gitlab-runner-vagrant-lxc.j2")
        (dest "/etc/sudoers.d/gitlab-runner-vagrant-lxc")
        (owner "root")
        (group "root")
        (mode "0440"))
      (when "(ansible_local | d() and ansible_local.sudo | d() and (ansible_local.sudo.installed | d()) | bool and gitlab_runner__vagrant_lxc | bool)"))
    (task "Make sure that Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save GitLab Runner local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/gitlab_runner.fact.j2")
        (dest "/etc/ansible/facts.d/gitlab_runner.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "meta::facts")))))
