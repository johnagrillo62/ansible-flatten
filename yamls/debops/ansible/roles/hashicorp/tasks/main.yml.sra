(playbook "debops/ansible/roles/hashicorp/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (hashicorp__base_packages
                              + hashicorp__packages
                              + hashicorp__dependent_packages)) }}"))
        (state "present"))
      (register "hashicorp__register_packages")
      (until "hashicorp__register_packages is succeeded")
      (when "(hashicorp__applications or hashicorp__dependent_applications)"))
    (task "Create HashiCorp group"
      (ansible.builtin.group 
        (name (jinja "{{ hashicorp__group }}"))
        (state "present")
        (system "True"))
      (when "(hashicorp__applications or hashicorp__dependent_applications)")
      (tags (list
          "role::hashicorp:download"
          "role::hashicorp:verify")))
    (task "Create HashiCorp user"
      (ansible.builtin.user 
        (name (jinja "{{ hashicorp__user }}"))
        (group (jinja "{{ hashicorp__group }}"))
        (home (jinja "{{ hashicorp__home }}"))
        (comment (jinja "{{ hashicorp__comment }}"))
        (shell (jinja "{{ hashicorp__shell }}"))
        (system "True")
        (state "present"))
      (when "(hashicorp__applications or hashicorp__dependent_applications)")
      (tags (list
          "role::hashicorp:download"
          "role::hashicorp:verify")))
    (task "Create source directories"
      (ansible.builtin.file 
        (path (jinja "{{ hashicorp__src + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] }}"))
        (state "directory")
        (owner (jinja "{{ hashicorp__user }}"))
        (group (jinja "{{ hashicorp__group }}"))
        (mode "0755"))
      (with_items (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}"))
      (when "(hashicorp__applications or hashicorp__dependent_applications)")
      (tags (list
          "role::hashicorp:download"
          "role::hashicorp:verify")))
    (task "Create library directories"
      (ansible.builtin.file 
        (path (jinja "{{ hashicorp__lib + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] }}"))
        (state "directory")
        (owner (jinja "{{ hashicorp__user }}"))
        (group (jinja "{{ hashicorp__group }}"))
        (mode "0750"))
      (with_items (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}"))
      (when "(hashicorp__applications or hashicorp__dependent_applications)")
      (tags (list
          "role::hashicorp:unpack"
          "role::hashicorp:install")))
    (task "Create Consul Web UI library directory"
      (ansible.builtin.file 
        (path (jinja "{{ hashicorp__lib + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] + \"/web_ui\" }}"))
        (state "directory")
        (owner (jinja "{{ hashicorp__user }}"))
        (group (jinja "{{ hashicorp__group }}"))
        (mode "0755"))
      (with_items (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}"))
      (when "(hashicorp__consul_webui | bool and item == 'consul')"))
    (task "Create Consul Web UI directory"
      (ansible.builtin.file 
        (path (jinja "{{ hashicorp__consul_webui_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(hashicorp__consul_webui | bool and ('consul' in (hashicorp__applications + hashicorp__dependent_applications | unique)))"))
    (task "Download and validate the tarballs"
      (block (list
          
          (name "Download requested application files")
          (ansible.builtin.get_url 
            (url (jinja "{{ hashicorp__base_url + item.0 + \"/\" +
                 hashicorp__combined_version_map[item.0] + \"/\" + item.0 + \"_\" +
                 hashicorp__combined_version_map[item.0] + \"_\" + item.1 }}"))
            (dest (jinja "{{ hashicorp__src + \"/\" + item.0 + \"/\" + hashicorp__combined_version_map[item.0] + \"/\" }}"))
            (mode "0644"))
          (with_nested (list
              (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}")
              (list
                (jinja "{{ hashicorp__tar_suffix }}")
                (jinja "{{ hashicorp__hash_suffix }}")
                (jinja "{{ hashicorp__sig_suffix }}"))))
          (when "(ansible_local.hashicorp is not defined or (ansible_local.hashicorp | d() and ansible_local.hashicorp.applications | d() and (ansible_local.hashicorp.applications[item.0] is not defined or (ansible_local.hashicorp.applications[item.0] != hashicorp__combined_version_map[item.0]))))")
          (tags (list
              "role::hashicorp:download"
              "role::hashicorp:verify"))
          
          (name "Download Consul Web UI")
          (ansible.builtin.get_url 
            (url (jinja "{{ hashicorp__base_url + item.0 + \"/\" +
                 hashicorp__combined_version_map[item.0] + \"/\" + item.0 + \"_\" +
                 hashicorp__combined_version_map[item.0] + \"_\" + item.1 }}"))
            (dest (jinja "{{ hashicorp__src + \"/\" + item.0 + \"/\" + hashicorp__combined_version_map[item.0] + \"/\" }}"))
            (mode "0644"))
          (with_nested (list
              (list
                "consul")
              (list
                (jinja "{{ hashicorp__consul_webui_suffix }}"))))
          (when "(hashicorp__consul_webui | bool and ('consul' in (hashicorp__applications + hashicorp__dependent_applications) | unique) and (ansible_local.hashicorp is not defined or (ansible_local.hashicorp | d() and ansible_local.hashicorp.applications | d() and (ansible_local.hashicorp.applications['consul'] is not defined or (ansible_local.hashicorp.applications['consul'] != hashicorp__combined_version_map['consul'])) or not ansible_local.hashicorp.consul_webui | bool)))")
          (tags (list
              "role::hashicorp:download"
              "role::hashicorp:verify"))
          
          (name "Verify signatures with HashiCorp GPG key")
          (ansible.builtin.command "gpg --verify " (jinja "{{ item + '_' + hashicorp__combined_version_map[item] + '_' + hashicorp__sig_suffix }}") " " (jinja "{{ item + '_' + hashicorp__combined_version_map[item] + '_' + hashicorp__hash_suffix }}"))
          (args 
            (chdir (jinja "{{ hashicorp__src + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] }}")))
          (with_items (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}"))
          (register "hashicorp__register_signature")
          (changed_when "False")
          (failed_when "hashicorp__register_signature.rc != 0")
          (tags (list
              "role::hashicorp:verify"))
          
          (name "Check file signatures")
          (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && grep --file <(find . -type f -printf \"%f$\\n\") " (jinja "{{ item + '_' + hashicorp__combined_version_map[item] + '_' + hashicorp__hash_suffix }}") " | sha256sum --check --status")
          (args 
            (chdir (jinja "{{ hashicorp__src + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] }}"))
            (executable "bash"))
          (with_items (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}"))
          (register "hashicorp__register_hash")
          (changed_when "False")
          (failed_when "hashicorp__register_hash.rc != 0")
          (tags (list
              "role::hashicorp:verify"))
          
          (name "Unpack the file archives")
          (ansible.builtin.unarchive 
            (remote_src "True")
            (src (jinja "{{ hashicorp__src + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] + \"/\" +
                 item + \"_\" + hashicorp__combined_version_map[item] + \"_\" + hashicorp__tar_suffix }}"))
            (dest (jinja "{{ hashicorp__lib + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] }}"))
            (mode "u=rwX,g=rwX,o=rX")
            (creates (jinja "{{ hashicorp__lib + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] + \"/\" +
                     ((hashicorp__combined_binary_map[item]
                       if hashicorp__combined_binary_map[item] is string
                       else hashicorp__combined_binary_map[item] | first)
                      if hashicorp__combined_binary_map[item] | d() else item) }}")))
          (with_items (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}"))
          (register "hashicorp__register_unpack")
          (tags (list
              "role::hashicorp:unpack"
              "role::hashicorp:install"))
          
          (name "Unpack the Consul Web UI")
          (ansible.builtin.unarchive 
            (copy "False")
            (src (jinja "{{ hashicorp__src + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] + \"/\" +
                 item + \"_\" + hashicorp__combined_version_map[item] + \"_\" + hashicorp__consul_webui_suffix }}"))
            (dest (jinja "{{ hashicorp__lib + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] + \"/web_ui\" + \"/\" }}"))
            (mode "u=rwX,g=rwX,o=rX")
            (creates (jinja "{{ hashicorp__lib + \"/\" + item + \"/\"
                     + hashicorp__combined_version_map[item] + \"/web_ui/index.html\" }}")))
          (with_items (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}"))
          (register "hashicorp__register_unpack_webui")
          (when "hashicorp__consul_webui | bool and item == 'consul'")
          (tags (list
              "role::hashicorp:unpack"
              "role::hashicorp:install"))))
      (become "True")
      (become_user (jinja "{{ hashicorp__user }}"))
      (when "(hashicorp__applications or hashicorp__dependent_applications)"))
    (task "Install HashiCorp applications"
      (ansible.builtin.shell "install --mode 755 --owner root --group root --target-directory " (jinja "{{ hashicorp__bin }}") " " (jinja "{{ ((hashicorp__combined_binary_map[item.0]
              if hashicorp__combined_binary_map[item.0] is string
              else hashicorp__combined_binary_map[item.0] | join(' '))
             if hashicorp__combined_binary_map[item.0] | d() else item.0) }}") " " (jinja "{% if item.0 == 'terraform' %}") " ; find . -maxdepth 1 -type f -name 'terraform-*' -exec install -m 755 -o root -g root -t " (jinja "{{ hashicorp__bin }}") " {} + " (jinja "{% endif %}"))
      (args 
        (chdir (jinja "{{ hashicorp__lib + \"/\" + item.0 + \"/\" + hashicorp__combined_version_map[item.0] }}")))
      (with_together (list
          (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}")
          (jinja "{{ hashicorp__register_unpack.results }}")))
      (register "hashicorp__register_app_install")
      (changed_when "hashicorp__register_app_install.changed | bool")
      (when "(item.1 is changed or (ansible_local | d() and (ansible_local.hashicorp is not defined or (ansible_local.hashicorp | d() and ansible_local.hashicorp.applications | d() and (ansible_local.hashicorp.applications[item.0] is not defined or (ansible_local.hashicorp.applications[item.0] != hashicorp__combined_version_map[item.0]))))))")
      (tags (list
          "role::hashicorp:install")))
    (task "Synchronize Consul Web UI public directory"
      (ansible.builtin.shell "rsync --delete --recursive --prune-empty-dirs " (jinja "{{ hashicorp__lib + \"/\" + item + \"/\" + hashicorp__combined_version_map[item] + \"/web_ui/\" }}") " " (jinja "{{ hashicorp__consul_webui_path }}") " && chown -R root:root " (jinja "{{ hashicorp__consul_webui_path }}"))
      (with_items (jinja "{{ (hashicorp__applications + hashicorp__dependent_applications) | unique }}"))
      (register "hashicorp__register_consul_ui_rsync")
      (changed_when "hashicorp__register_consul_ui_sync.changed | bool")
      (when "(hashicorp__consul_webui | bool and item == 'consul' and hashicorp__register_unpack_webui is changed)"))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(hashicorp__applications or hashicorp__dependent_applications)"))
    (task "Save HashiCorp local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/hashicorp.fact.j2")
        (dest "/etc/ansible/facts.d/hashicorp.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (when "(hashicorp__applications or hashicorp__dependent_applications)")
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
