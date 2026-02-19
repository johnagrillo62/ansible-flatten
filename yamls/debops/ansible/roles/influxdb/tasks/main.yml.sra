(playbook "debops/ansible/roles/influxdb/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Check if database server is installed"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && dpkg-query -W -f='${Version}\\n' 'influxdb' | grep -v '^$'")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "bash"))
      (register "influxdb__register_version")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False"))
    (task "Override configuration if local server is detected"
      (ansible.builtin.set_fact 
        (influxdb__server (jinja "{{ ansible_fqdn if influxdb__pki else \"localhost\" }}")))
      (when "(influxdb__register_version.stdout | d(False))"))
    (task "Make sure that local fact directory exists"
      (ansible.builtin.file 
        (dest "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save InfluxDB local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/influxdb.fact.j2")
        (dest "/etc/ansible/facts.d/influxdb.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Manage database contents"
      (ansible.builtin.include_tasks "manage_contents.yml")
      (when "(influxdb__server | d(False) and influxdb__delegate_to)")
      (tags (list
          "role::influxdb:contents")))))
