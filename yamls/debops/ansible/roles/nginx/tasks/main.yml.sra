(playbook "debops/ansible/roles/nginx/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "DebOps pre_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"nginx/pre_main.yml\") }}"))
      (when "(nginx__deploy_state in ['present'])"))
    (task "Assert that no legacy options are used"
      (ansible.builtin.assert 
        (that (list
            "((item.csp is defined and item.csp is string) or item.csp is undefined)"
            "(item.csp_policy is undefined)")))
      (run_once "True")
      (delegate_to "localhost")
      (loop (jinja "{{ q(\"flattened\", nginx__servers
                           + nginx__default_servers
                           + nginx__internal_servers
                           + nginx__dependent_servers
                           + nginx_servers | d([])
                           + nginx_default_servers | d([])
                           + nginx_internal_servers | d([])
                           + nginx_dependent_servers | d([])) }}")))
    (task "Check if nginx is installed"
      (ansible.builtin.stat 
        (path "/usr/sbin/nginx"))
      (register "nginx_register_installed"))
    (task "Ensure base packages are installed"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", nginx_base_packages) }}"))
        (state "present"))
      (when "(nginx__deploy_state in ['present'])")
      (register "nginx__register_packages_present")
      (until "nginx__register_packages_present is succeeded"))
    (task "Ensure Nginx packages are in their desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", nginx__flavor_packages) }}"))
        (state (jinja "{{ \"present\" if (nginx__deploy_state == \"present\") else \"absent\" }}")))
      (register "nginx__register_packages_flavor")
      (until "nginx__register_packages_flavor is succeeded"))
    (task "Create systemd override directory for nginx unit"
      (ansible.builtin.file 
        (path "/etc/systemd/system/nginx.service.d")
        (state "directory")
        (mode "0755"))
      (when "nginx__deploy_state in ['present', 'config'] and ansible_service_mgr == 'systemd' and ansible_distribution_release in [\"stretch\", \"buster\", \"bullseye\", \"trusty\", \"xenial\", \"bionic\", \"focal\", \"jammy\", \"lunar\"]"))
    (task "Create systemd override configuration for nginx unit"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/systemd/system/nginx.service.d/wait-for-network.conf.j2\") }}"))
        (dest "/etc/systemd/system/nginx.service.d/wait-for-network.conf")
        (mode "0644"))
      (notify (list
          "Reload systemd daemon"))
      (when "nginx__deploy_state in ['present', 'config'] and ansible_service_mgr == 'systemd' and ansible_distribution_release in [\"stretch\", \"buster\", \"bullseye\", \"trusty\", \"xenial\", \"bionic\", \"focal\", \"jammy\", \"lunar\"]"))
    (task "Remove systemd override configuration for nginx unit"
      (ansible.builtin.file 
        (path "/etc/systemd/system/nginx.service.d/wait-for-network.conf")
        (state "absent"))
      (notify (list
          "Reload systemd daemon"))
      (when "ansible_distribution_release not in [\"stretch\", \"buster\", \"bullseye\", \"trusty\", \"xenial\", \"bionic\", \"focal\", \"jammy\", \"lunar\"]"))
    (task "Remove systemd override directory for nginx unit, if empty"
      (ansible.builtin.command "rmdir /etc/systemd/system/nginx.service.d/")
      (register "nginx__register_rmdir_systemd")
      (changed_when "nginx__register_rmdir_systemd.rc == 0")
      (failed_when "False")
      (when "ansible_distribution_release not in [\"stretch\", \"buster\", \"bullseye\", \"trusty\", \"xenial\", \"bionic\", \"focal\", \"jammy\", \"lunar\"]"))
    (task "Make sure that Ansible local facts directory is present"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Save nginx local facts"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/ansible/facts.d/nginx.fact.j2\") }}"))
        (dest "/etc/ansible/facts.d/nginx.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "(nginx__deploy_state in ['present', 'config'])")
      (tags (list
          "meta::facts")))
    (task "Gather facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Create default nginx directories"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (list
          "/etc/nginx/sites-default.d"
          "/etc/nginx/sites-available"
          "/etc/nginx/sites-enabled"
          "/etc/nginx/snippets"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Divert default.conf in case nginx nginx.org flavor is used"
      (debops.debops.dpkg_divert 
        (path "/etc/nginx/conf.d/default.conf"))
      (when "(nginx_flavor == 'nginx.org' and nginx__deploy_state in ['present', 'config'])"))
    (task "Configure Passenger support"
      (ansible.builtin.include_tasks "passenger_config.yml")
      (when "(nginx_flavor == 'passenger' and nginx__deploy_state in ['present', 'config'])"))
    (task "Restart nginx on first install to bypass missing pid bug"
      (ansible.builtin.service 
        (name "nginx")
        (state "restarted"))
      (when "(nginx_register_installed | d() and not nginx_register_installed.stat.exists and nginx__deploy_state in ['present', 'config'])"))
    (task "Get list of nameservers configured in /etc/resolv.conf"
      (ansible.builtin.shell "awk '$1==\"nameserver\" {if(/%/){sub(/[0-9a-fA-F:]+/, \"[&]\", $2)}; print $2}' /etc/resolv.conf")
      (args 
        (executable "sh"))
      (register "nginx_register_nameservers")
      (changed_when "False")
      (check_mode "False")
      (when "(nginx__deploy_state in ['present', 'config'])")
      (tags (list
          "role::nginx:servers")))
    (task "Convert list of nameservers to Ansible list"
      (ansible.builtin.set_fact 
        (nginx_ocsp_resolvers (jinja "{{ nginx_register_nameservers.stdout_lines }}")))
      (when "((nginx_register_nameservers.stdout is defined and nginx_register_nameservers.stdout) and (nginx_ocsp_resolvers is undefined or (nginx_ocsp_resolvers is defined and not nginx_ocsp_resolvers)) and (nginx__deploy_state in ['present', 'config']))")
      (tags (list
          "role::nginx:servers")))
    (task "Ensure that webadmins privileged group exists"
      (ansible.builtin.group 
        (name (jinja "{{ nginx_privileged_group }}"))
        (state "present")
        (system "True"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Create directory for webadmins configuration"
      (ansible.builtin.file 
        (path "/etc/nginx/sites-local")
        (state "directory")
        (owner "root")
        (group (jinja "{{ nginx_privileged_group }}"))
        (mode "0775"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Allow webadmins to control nginx system service using sudo"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/sudoers.d/nginx_webadmins.j2\") }}"))
        (dest "/etc/sudoers.d/nginx_webadmins")
        (owner "root")
        (group "root")
        (mode "0440"))
      (when "(ansible_local | d() and ansible_local.sudo | d() and (ansible_local.sudo.installed | d()) | bool and nginx__deploy_state in ['present', 'config'])"))
    (task "Divert original /etc/nginx/nginx.conf"
      (debops.debops.dpkg_divert 
        (path "/etc/nginx/nginx.conf"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Setup /etc/nginx/nginx.conf"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/nginx/nginx.conf.j2\") }}"))
        (dest "/etc/nginx/nginx.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Test nginx and reload"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Generate custom nginx snippets"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/nginx/snippets/\" + item + \".conf.j2\") }}"))
        (dest "/etc/nginx/snippets/" (jinja "{{ item }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "acme-challenge"
          "ssl"))
      (when "(nginx__deploy_state in ['present', 'config'])")
      (notify (list
          "Test nginx and reload")))
    (task "Disable default nginx site"
      (ansible.builtin.file 
        (path "/etc/nginx/sites-enabled/default")
        (state "absent"))
      (notify (list
          "Test nginx and reload"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Manage local server definitions - create symlinks"
      (ansible.builtin.file 
        (src "/etc/nginx/sites-local/" (jinja "{{ item.value }}"))
        (path "/etc/nginx/sites-enabled/" (jinja "{{ item.key }}"))
        (state "link")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "(item.value and nginx__deploy_state in ['present', 'config'])")
      (with_dict (jinja "{{ nginx_local_servers | d({}) }}"))
      (notify (list
          "Test nginx and reload")))
    (task "Manage local server definitions - remove symlinks"
      (ansible.builtin.file 
        (path "/etc/nginx/sites-enabled/" (jinja "{{ item.key }}"))
        (state "absent"))
      (when "((not item.value | d()) and nginx__deploy_state in ['present', 'config'])")
      (with_dict (jinja "{{ nginx_local_servers | d({}) }}"))
      (notify (list
          "Test nginx and reload")))
    (task "Remove all configuration symlinks during config reset"
      (ansible.builtin.shell "rm -f /etc/nginx/sites-enabled/*")
      (args 
        (executable "sh")
        (creates "/etc/ansible/facts.d/nginx.fact"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Configure htpasswd files"
      (ansible.builtin.include_tasks "nginx_htpasswd.yml")
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Generate nginx conf.d/ files"
      (ansible.builtin.include_tasks "nginx_configs.yml")
      (tags (list
          "role::nginx:servers"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Generate nginx server configuration"
      (ansible.builtin.include_tasks "nginx_servers.yml")
      (tags (list
          "role::nginx:servers"))
      (when "(nginx__deploy_state in ['present', 'config'])"))
    (task "Make sure that PKI hook directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ nginx_pki_hook_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(nginx_pki | bool and nginx__deploy_state in ['present', 'config'])"))
    (task "Manage PKI nginx hook"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/pki/hooks/nginx.j2\") }}"))
        (dest (jinja "{{ nginx_pki_hook_path + \"/\" + nginx_pki_hook_name }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(nginx_pki | bool and nginx__deploy_state in ['present', 'config'])"))
    (task "Ensure the PKI nginx hook is absent"
      (ansible.builtin.file 
        (path (jinja "{{ nginx_pki_hook_path + \"/\" + nginx_pki_hook_name }}"))
        (state "absent"))
      (when "(nginx__deploy_state in ['absent'])"))
    (task "Save nginx local facts"
      (ansible.builtin.template 
        (src (jinja "{{ lookup(\"debops.debops.template_src\", \"etc/ansible/facts.d/nginx.fact.j2\") }}"))
        (dest "/etc/ansible/facts.d/nginx.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts")))
    (task "Gather facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "DebOps post_tasks hook"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"nginx/post_main.yml\") }}"))
      (when "(nginx__deploy_state in [ 'present' ])"))))
