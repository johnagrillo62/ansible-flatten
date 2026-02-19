(playbook "debops/ansible/roles/influxdb_server/tasks/main.yml"
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
    (task "Restart database server on first install (influx bug)"
      (ansible.builtin.service 
        (name "influxdb")
        (state "restarted"))
      (when "not (ansible_local.influxdb_server.installed | d(false) | bool)"))
    (task "Wait for HTTP endpoint port to become open on the host on first install"
      (ansible.builtin.wait_for 
        (port (jinja "{{ influxdb_server__port }}")))
      (when "not (ansible_local.influxdb_server.installed | d(false) | bool)"))
    (task "Create default admin user on first install"
      (community.general.influxdb_user 
        (user_name "root")
        (user_password (jinja "{{ influxdb_server__root_password }}"))
        (state "present")
        (admin "yes")
        (proxies 
          (http null)
          (https null)))
      (when "not (ansible_local.influxdb_server.installed | d(false) | bool)")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Stop database server on first install"
      (ansible.builtin.service 
        (name "influxdb")
        (state "stopped"))
      (when "not (ansible_local.influxdb_server.installed | d(false) | bool)"))
    (task "Add InfluxDB server user to specified groups"
      (ansible.builtin.user 
        (name "influxdb")
        (groups (jinja "{{ influxdb_server__append_groups | join(\",\") | default(omit) }}"))
        (append "True")
        (createhome "False"))
      (when "influxdb_server__pki | bool"))
    (task "Ensure InfluxDB server directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ influxdb_server__directory }}"))
        (state "directory")
        (owner "influxdb")
        (group "influxdb")
        (mode "0750")))
    (task "Move InfluxDB data files to data directory"
      (ansible.builtin.shell "mv " (jinja "{{ influxdb_server__default_directory }}") "/* " (jinja "{{ influxdb_server__directory }}"))
      (register "influxdb_server__register_move")
      (changed_when "influxdb_server__register_move.changed | bool")
      (when "(not (ansible_local.influxdb_server.installed | d(false) | bool) and influxdb_server__directory != influxdb_server__default_directory)"))
    (task "Divert the original influxdb configuration file"
      (debops.debops.dpkg_divert 
        (path "/etc/influxdb/influxdb.conf")
        (state "present")
        (delete "True"))
      (tags (list
          "role::influxdb_server:config")))
    (task "Configure InfluxDB server"
      (ansible.builtin.template 
        (src "etc/influxdb/influxdb.conf.j2")
        (dest "/etc/influxdb/influxdb.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (tags (list
          "role::influxdb_server:config"))
      (notify (list
          "Restart influxdb")))
    (task "Start database server on first install"
      (ansible.builtin.service 
        (name "influxdb")
        (state "started"))
      (when "not (ansible_local.influxdb_server.installed | d(false) | bool)"))
    (task "Configure autoinfluxdbbackup"
      (ansible.builtin.include_tasks "autoinfluxdbbackup.yml")
      (when "influxdb_server__backup | bool")
      (tags (list
          "role::influxdb_server:autoinfluxdbbackup")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save InfluxDB server local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/influxdb_server.fact.j2")
        (dest "/etc/ansible/facts.d/influxdb_server.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Save InfluxDB local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/influxdb.fact.j2")
        (dest "/etc/ansible/facts.d/influxdb.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
