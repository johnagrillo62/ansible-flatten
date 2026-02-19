(playbook "debops/ansible/roles/mosquitto/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Check if supported version of libwebsockets is available"
      (ansible.builtin.command "apt-cache -q madison " (jinja "{{ mosquitto__websockets_packages | join(' ') }}"))
      (register "mosquitto__register_websockets")
      (when "ansible_pkg_mgr == 'apt'")
      (changed_when "False")
      (check_mode "False"))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (mosquitto__base_packages
                              + mosquitto__packages)) }}"))
        (state "present"))
      (register "mosquitto__register_packages")
      (until "mosquitto__register_packages is succeeded"))
    (task "Install required Python modules"
      (ansible.builtin.pip 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (jinja "{{ mosquitto__pip_packages }}"))
      (register "mosquitto__register_pip_install")
      (until "mosquitto__register_pip_install is succeeded")
      (when "mosquitto__pip_packages | d()"))
    (task "Check the installed Mosquitto version"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && mosquitto -h | head -n 1 | awk '{print $3}' || true")
      (args 
        (executable "bash"))
      (register "mosquitto__register_version")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::mosquitto:passwd")))
    (task "Ensure that the required UNIX group exists"
      (ansible.builtin.group 
        (name (jinja "{{ mosquitto__group }}"))
        (state "present")
        (system "True")))
    (task "Add Mosquitto user to specified system groups"
      (ansible.builtin.user 
        (name (jinja "{{ mosquitto__user }}"))
        (group (jinja "{{ mosquitto__group }}"))
        (groups (jinja "{{ ([mosquitto__append_groups]
                 if mosquitto__append_groups is string
                 else mosquitto__append_groups) | join(\",\") }}"))
        (append "True"))
      (notify (list
          "Restart mosquitto")))
    (task "Make sure the password file exists"
      (ansible.builtin.file 
        (path (jinja "{{ mosquitto__password_file }}"))
        (state (jinja "{{ \"file\" if (ansible_local.mosquitto.password | d() | bool) else \"touch\" }}"))
        (owner "root")
        (group (jinja "{{ mosquitto__group }}"))
        (mode "0640"))
      (when "mosquitto__password | bool")
      (tags (list
          "role::mosquitto:passwd")))
    (task "Check current list of user entries"
      (ansible.builtin.command "awk -F ':' '{print $1}' " (jinja "{{ mosquitto__password_file }}"))
      (register "mosquitto__register_passwd")
      (when "mosquitto__password | bool")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::mosquitto:passwd")))
    (task "Remove user/password entries"
      (ansible.builtin.command "mosquitto_passwd -D " (jinja "{{ mosquitto__password_file }}") " " (jinja "{{ item.name | d(item) }}"))
      (loop (jinja "{{ q(\"flattened\", mosquitto__auth_users
                           + mosquitto__auth_group_users
                           + mosquitto__auth_host_users) }}"))
      (register "mosquitto__register_passwd_remove")
      (changed_when "mosquitto__register_passwd_remove.changed | bool")
      (when "(mosquitto__password | bool and item.state | d('present') == 'absent' and (item.name | d(item) in mosquitto__register_passwd.stdout_lines) and mosquitto__version is version_compare('1.4.0', '>='))")
      (notify (list
          "Reload mosquitto"))
      (tags (list
          "role::mosquitto:passwd"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create user/password entries"
      (ansible.builtin.command "mosquitto_passwd -b " (jinja "{{ mosquitto__password_file }}") " " (jinja "{{ item.name | d(item) }}") " ${MOSQUITTO_PASSWORD}")
      (environment 
        (MOSQUITTO_PASSWORD (jinja "{{ item.password
                            | d(lookup(\"password\", mosquitto__password_secret_path + \"/\" + item.name | d(item))) }}")))
      (loop (jinja "{{ q(\"flattened\", mosquitto__auth_users
                           + mosquitto__auth_group_users
                           + mosquitto__auth_host_users) }}"))
      (register "mosquitto__register_passwd_create")
      (changed_when "mosquitto__register_passwd_create.changed | bool")
      (when "(mosquitto__password | bool and item.state | d('present') != 'absent' and (item.name | d(item) not in mosquitto__register_passwd.stdout_lines) and mosquitto__version is version_compare('1.4.0', '>='))")
      (notify (list
          "Reload mosquitto"))
      (tags (list
          "role::mosquitto:passwd"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Manage Mosquitto ACL file"
      (ansible.builtin.template 
        (src "etc/mosquitto/acl.j2")
        (dest (jinja "{{ mosquitto__acl_file }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "mosquitto__acl | bool")
      (notify (list
          "Reload mosquitto"))
      (tags (list
          "role::mosquitto:acl")))
    (task "Remove Mosquitto default configuration if empty"
      (ansible.builtin.file 
        (path "/etc/mosquitto/conf.d/00_default.conf")
        (state "absent"))
      (when "not mosquitto__combined_options | d()")
      (notify (list
          "Restart mosquitto"))
      (tags (list
          "role::mosquitto:config"
          "role::mosquitto:passwd"
          "role::mosquitto:acl")))
    (task "Generate Mosquitto default configuration"
      (ansible.builtin.template 
        (src "etc/mosquitto/conf.d/default.conf.j2")
        (dest "/etc/mosquitto/conf.d/00_default.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart mosquitto"))
      (tags (list
          "role::mosquitto:config"
          "role::mosquitto:passwd"
          "role::mosquitto:acl")))
    (task "Remove Mosquitto listener configuration"
      (ansible.builtin.file 
        (dest "/etc/mosquitto/conf.d/listener_" (jinja "{{ item.key }}") ".conf")
        (state "absent"))
      (with_dict (jinja "{{ mosquitto__combined_listeners }}"))
      (notify (list
          "Restart mosquitto"))
      (when "item.value.state | d('present') == 'absent'")
      (tags (list
          "role::mosquitto:listeners")))
    (task "Generate Mosquitto listener configuration"
      (ansible.builtin.template 
        (src "etc/mosquitto/conf.d/listener.conf.j2")
        (dest "/etc/mosquitto/conf.d/listener_" (jinja "{{ item.key }}") ".conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_dict (jinja "{{ mosquitto__combined_listeners }}"))
      (notify (list
          "Restart mosquitto"))
      (when "item.value.state | d('present') != 'absent'")
      (tags (list
          "role::mosquitto:listeners")))
    (task "Remove Mosquitto bridge configuration"
      (ansible.builtin.file 
        (dest "/etc/mosquitto/conf.d/bridge_" (jinja "{{ item.value.connection | d(item.key) }}") ".conf")
        (state "absent"))
      (with_dict (jinja "{{ mosquitto__combined_bridges }}"))
      (notify (list
          "Restart mosquitto"))
      (when "item.value.state | d('present') == 'absent'")
      (tags (list
          "role::mosquitto:bridges")))
    (task "Generate Mosquitto bridge configuration"
      (ansible.builtin.template 
        (src "etc/mosquitto/conf.d/bridge.conf.j2")
        (dest "/etc/mosquitto/conf.d/bridge_" (jinja "{{ item.value.connection | d(item.key) }}") ".conf")
        (owner "root")
        (group (jinja "{{ item.value.group | d(\"root\") }}"))
        (mode (jinja "{{ item.value.mode | d(\"0644\") }}")))
      (with_dict (jinja "{{ mosquitto__combined_bridges }}"))
      (notify (list
          "Restart mosquitto"))
      (when "item.value.state | d('present') != 'absent'")
      (tags (list
          "role::mosquitto:bridges")))
    (task "Make sure that Avahi service directory exists"
      (ansible.builtin.file 
        (path "/etc/avahi/services")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "mosquitto__avahi | bool")
      (tags (list
          "role::mosquitto:avahi"
          "role::mosquitto:listeners")))
    (task "Generate Avahi Mosquitto service file"
      (ansible.builtin.template 
        (src "etc/avahi/services/mosquitto.service.j2")
        (dest "/etc/avahi/services/mosquitto.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "mosquitto__avahi | bool")
      (tags (list
          "role::mosquitto:avahi"
          "role::mosquitto:listeners")))
    (task "Make sure that WebSockets public HTTP directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ mosquitto__http_dir_path }}"))
        (state "directory")
        (owner (jinja "{{ mosquitto__http_dir_owner }}"))
        (group (jinja "{{ mosquitto__http_dir_group }}"))
        (mode (jinja "{{ mosquitto__http_dir_mode }}")))
      (when "mosquitto__websockets | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (tags (list
          "role::mosquitto:passwd")))
    (task "Save Mosquitto local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/mosquitto.fact.j2")
        (dest "/etc/ansible/facts.d/mosquitto.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts"
          "role::mosquitto:passwd")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers")
      (tags (list
          "role::mosquitto:passwd")))))
