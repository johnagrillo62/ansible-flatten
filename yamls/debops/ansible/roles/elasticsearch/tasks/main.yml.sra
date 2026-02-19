(playbook "debops/ansible/roles/elasticsearch/tasks/main.yml"
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
    (task "Install Elasticsearch packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (elasticsearch__base_packages
                              + elasticsearch__packages)) }}"))
        (state "present"))
      (notify (list
          "Refresh host facts"))
      (register "elasticsearch__register_packages")
      (until "elasticsearch__register_packages is succeeded"))
    (task "Add Elasticsearch UNIX account to selected groups"
      (ansible.builtin.user 
        (name (jinja "{{ elasticsearch__user }}"))
        (groups (jinja "{{ elasticsearch__additional_groups }}"))
        (append "True"))
      (when "elasticsearch__additional_groups | d()"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Elasticsearch local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/elasticsearch.fact.j2")
        (dest "/etc/ansible/facts.d/elasticsearch.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Check if the dependent config file exists"
      (ansible.builtin.stat 
        (path (jinja "{{ secret + \"/elasticsearch/dependent_config/\" + inventory_hostname + \"/config.json\" }}")))
      (register "elasticsearch__register_dependent_config_file")
      (become "False")
      (delegate_to "localhost")
      (when "(ansible_local.elasticsearch.installed | d())")
      (tags (list
          "role::elasticsearch:config")))
    (task "Load the dependent configuration from Ansible Controller"
      (ansible.builtin.slurp 
        (src (jinja "{{ secret + \"/elasticsearch/dependent_config/\" + inventory_hostname + \"/config.json\" }}")))
      (register "elasticsearch__register_dependent_config")
      (become "False")
      (delegate_to "localhost")
      (when "(ansible_local.elasticsearch.installed | d() and elasticsearch__register_dependent_config_file.stat.exists | bool)")
      (tags (list
          "role::elasticsearch:config")))
    (task "Divert original configuration files"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ item }}")))
      (loop (list
          "/etc/elasticsearch/elasticsearch.yml"
          "/etc/elasticsearch/jvm.options"
          "/usr/lib/sysctl.d/elasticsearch.conf"
          "/usr/share/elasticsearch/jdk/conf/security/java.policy"))
      (notify (list
          "Start elasticsearch"))
      (tags (list
          "role::elasticsearch:config")))
    (task "Create systemd configuration directory"
      (ansible.builtin.file 
        (path "/etc/systemd/system/elasticsearch.service.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Generate systemd configuration"
      (ansible.builtin.template 
        (src "etc/systemd/system/elasticsearch.service.d/ansible.conf.j2")
        (dest "/etc/systemd/system/elasticsearch.service.d/ansible.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload service manager")))
    (task "Generate Elasticsearch configuration"
      (ansible.builtin.template 
        (src "etc/elasticsearch/elasticsearch.yml.j2")
        (dest "/etc/elasticsearch/elasticsearch.yml")
        (owner "root")
        (group (jinja "{{ elasticsearch__group }}"))
        (mode "0660"))
      (notify (list
          "Restart elasticsearch"))
      (tags (list
          "role::elasticsearch:config")))
    (task "Generate Elasticsearch JVM configuration"
      (ansible.builtin.template 
        (src "etc/elasticsearch/jvm.options.j2")
        (dest "/etc/elasticsearch/jvm.options")
        (owner "root")
        (group (jinja "{{ elasticsearch__group }}"))
        (mode "0660"))
      (notify (list
          "Restart elasticsearch"))
      (when "elasticsearch__version is version(\"5.0.0\", \">=\")")
      (tags (list
          "role::elasticsearch:config")))
    (task "Generate Java Policy configuration file"
      (ansible.builtin.template 
        (src "usr/share/elasticsearch/jdk/conf/security/java.policy.j2")
        (dest "/usr/share/elasticsearch/jdk/conf/security/java.policy")
        (mode "0644"))
      (notify (list
          "Restart elasticsearch"))
      (when "elasticsearch__version is version(\"7.0.0\", \">=\")"))
    (task "Manage data paths"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ elasticsearch__user }}"))
        (group (jinja "{{ elasticsearch__group }}"))
        (mode "0750"))
      (loop (jinja "{{ q(\"flattened\", elasticsearch__path_data) }}")))
    (task "Reload systemd daemons"
      (ansible.builtin.meta "flush_handlers"))
    (task "Check state of installed Elasticsearch plugins"
      (ansible.builtin.command "bin/elasticsearch-plugin list")
      (args 
        (chdir "/usr/share/elasticsearch"))
      (register "elasticsearch__register_plugins")
      (changed_when "False")
      (check_mode "False"))
    (task "Install Elasticsearch plugins"
      (ansible.builtin.command "bin/elasticsearch-plugin install " (jinja "{{ item.url | d(item.name) }}") " --batch")
      (args 
        (chdir "/usr/share/elasticsearch"))
      (notify (list
          "Restart elasticsearch"))
      (loop (jinja "{{ q(\"flattened\", elasticsearch__combined_plugins) }}"))
      (register "elasticsearch__register_plugin_install")
      (changed_when "elasticsearch__register_plugin_install.changed | bool")
      (when "(item.name | d() and item.state | d('present') != 'absent' and (item.name if ':' not in item.name else item.name.split(':')[1]) not in elasticsearch__register_plugins.stdout_lines)"))
    (task "Remove Elasticsearch plugins"
      (ansible.builtin.command "bin/elasticsearch-plugin remove " (jinja "{{ item.name }}"))
      (args 
        (chdir "/usr/share/elasticsearch"))
      (notify (list
          "Restart elasticsearch"))
      (loop (jinja "{{ q(\"flattened\", elasticsearch__combined_plugins) }}"))
      (register "elasticsearch__register_plugin_remove")
      (changed_when "elasticsearch__register_plugin_remove.changed | bool")
      (when "(item.name | d() and item.state | d('present') == 'absent' and (item.name if ':' not in item.name else item.name.split(':')[1]) in elasticsearch__register_plugins.stdout_lines)"))
    (task "Save Elasticsearch dependent configuration on Ansible Controller"
      (ansible.builtin.template 
        (src "secret/elasticsearch/dependent_config/config.json.j2")
        (dest (jinja "{{ secret + \"/elasticsearch/dependent_config/\" + inventory_hostname + \"/config.json\" }}"))
        (mode "0644"))
      (become "False")
      (delegate_to "localhost")
      (tags (list
          "role::elasticsearch:config")))
    (task "Ensure that Elasticsearch is restarted"
      (ansible.builtin.meta "flush_handlers"))
    (task "Manage Elasticsearch authentication (old)"
      (ansible.builtin.import_tasks "authentication.yml")
      (run_once "True")
      (when "elasticsearch__version is version(\"8.0\", \"<\") and elasticsearch__xpack_enabled | bool and elasticsearch__pki_enabled | bool"))
    (task "Manage Elasticsearch authentication (new)"
      (ansible.builtin.import_tasks "authentication_v8.yml")
      (run_once "True")
      (when "elasticsearch__version is version(\"8.0\", \">=\") and elasticsearch__xpack_enabled | bool and elasticsearch__pki_enabled | bool"))
    (task "Manage Elasticsearch roles and users"
      (ansible.builtin.import_tasks "roles_users.yml")
      (run_once "True")
      (when "elasticsearch__xpack_enabled | bool and elasticsearch__pki_enabled | bool"))))
