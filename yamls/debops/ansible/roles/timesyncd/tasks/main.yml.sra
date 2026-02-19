(playbook "debops/ansible/roles/timesyncd/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Check if other time daemons are installed"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
dpkg --get-selections | grep -w -E '(" (jinja "{{ timesyncd__skip_packages | join(\"|\") }}") ")'
                      | awk '{print $1}' || true
")
      (environment 
        (LC_MESSAGES "C"))
      (args 
        (executable "/bin/bash"))
      (register "timesyncd__register_time_daemons")
      (changed_when "False")
      (failed_when "False")
      (check_mode "False"))
    (task "Set timesyncd deployment state"
      (ansible.builtin.set_fact 
        (timesyncd__fact_service_state (jinja "{{ \"present\"
                                       if (not timesyncd__register_time_daemons.stdout | d())
                                       else \"absent\" }}"))))
    (task "Install required timesyncd packages"
      (ansible.builtin.package 
        (name (jinja "{{ timesyncd__base_packages + timesyncd__packages }}"))
        (state "present"))
      (register "timesyncd__register_packages")
      (until "timesyncd__register_packages is succeeded")
      (when "timesyncd__enabled | bool"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755"))
      (when "timesyncd__enabled | bool"))
    (task "Save timesyncd local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/timesyncd.fact.j2")
        (dest "/etc/ansible/facts.d/timesyncd.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (when "timesyncd__enabled | bool")
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Remove systemd-timesyncd configuration if requested"
      (ansible.builtin.file 
        (path "/etc/systemd/timesyncd.conf.d/ansible.conf")
        (state "absent"))
      (notify (list
          "Restart systemd-timesyncd service"))
      (when "timesyncd__enabled | bool and timesyncd__deploy_state == 'absent'"))
    (task "Create systemd-timesyncd configuration directory"
      (ansible.builtin.file 
        (path "/etc/systemd/timesyncd.conf.d")
        (state "directory")
        (mode "0755"))
      (when "timesyncd__enabled | bool and timesyncd__deploy_state != 'absent'"))
    (task "Generate systemd-timesyncd configuration"
      (ansible.builtin.template 
        (src "etc/systemd/timesyncd.conf.d/ansible.conf.j2")
        (dest "/etc/systemd/timesyncd.conf.d/ansible.conf")
        (mode "0644"))
      (notify (list
          "Restart systemd-timesyncd service"))
      (when "timesyncd__enabled | bool and timesyncd__deploy_state != 'absent'"))
    (task "Flush handlers when needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Prepare cleanup during package removal"
      (ansible.builtin.import_role 
        (name "dpkg_cleanup"))
      (vars 
        (dpkg_cleanup__dependent_packages (list
            (jinja "{{ timesyncd__dpkg_cleanup__dependent_packages }}"))))
      (when "timesyncd__enabled | bool")
      (tags (list
          "role::dpkg_cleanup"
          "skip::dpkg_cleanup"
          "role::timesyncd:dpkg_cleanup")))))
