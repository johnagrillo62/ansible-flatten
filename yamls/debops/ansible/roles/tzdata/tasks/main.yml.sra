(playbook "debops/ansible/roles/tzdata/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", tzdata__base_packages + tzdata__packages) }}"))
        (state (jinja "{{ \"present\"
               if ((ansible_local.tzdata.configured | d()) | bool)
               else \"latest\" }}")))
      (register "tzdata__register_packages")
      (until "tzdata__register_packages is succeeded")
      (when "tzdata__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (when "tzdata__enabled | bool and not ansible_local | d()"))
    (task "Save tzdata local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/tzdata.fact.j2")
        (dest "/etc/ansible/facts.d/tzdata.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "tzdata__enabled | bool")
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Configure the time zone"
      (community.general.timezone 
        (name (jinja "{{ tzdata__timezone }}")))
      (register "tzdata__register_timezone")
      (notify (list
          "Refresh host facts"))
      (when "(tzdata__enabled | bool and ansible_service_mgr == \"systemd\" and (ansible_local.tzdata.timezone | d('Etc/UTC')) != tzdata__timezone)"))
    (task "Execute legacy timezone tasks"
      (ansible.builtin.include_tasks "legacy.yml")
      (when "(tzdata__enabled | bool and ansible_service_mgr != \"systemd\" and (ansible_local.tzdata.timezone | d('Etc/UTC')) != tzdata__timezone)"))
    (task "Update Ansible facts if time zone was modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Get list of currently running systemd services"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && systemctl list-units --state active | awk 'match($1, /\\./) {print $1}'")
      (args 
        (executable "bash"))
      (register "tzdata__register_services")
      (changed_when "tzdata__register_services.changed | bool")
      (when "(tzdata__enabled | bool and ansible_service_mgr == 'systemd' and tzdata__register_timezone is changed)"))
    (task "Request restart of services affected by time zone modification"
      (ansible.builtin.systemd 
        (name (jinja "{{ item }}"))
        (state "restarted")
        (no_block "True"))
      (loop (jinja "{{ q(\"flattened\", (tzdata__restart_default_services
                            + tzdata__restart_services)) }}"))
      (when "(tzdata__enabled | bool and ansible_service_mgr == 'systemd' and tzdata__register_timezone is changed and item in tzdata__register_services.stdout_lines)"))))
