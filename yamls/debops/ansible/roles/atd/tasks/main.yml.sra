(playbook "debops/ansible/roles/atd/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install atd"
      (ansible.builtin.apt 
        (name "at")
        (state (jinja "{{ \"present\" if atd_enabled | bool else \"absent\" }}"))
        (purge "True")
        (install_recommends "False"))
      (register "atd__register_packages")
      (until "atd__register_packages is succeeded"))
    (task "Generate consistent atd variables"
      (ansible.builtin.set_fact 
        (atd_fact_batch_interval (jinja "{{ atd_batch_interval }}"))
        (atd_fact_batch_load (jinja "{{ atd_batch_load }}")))
      (when "atd_enabled | bool")
      (tags (list
          "meta::facts")))
    (task "Configure atd and batch"
      (ansible.builtin.template 
        (src "etc/default/atd.j2")
        (dest "/etc/default/atd")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart atd"))
      (when "atd_enabled | bool"))
    (task "Install custom atd.service unit"
      (ansible.builtin.template 
        (src "etc/systemd/system/atd.service.j2")
        (dest "/etc/systemd/system/atd.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "atd_enabled | bool")
      (notify (list
          "Reload systemd units"
          "Restart atd")))
    (task "Configure /etc/at.allow"
      (ansible.builtin.lineinfile 
        (dest "/etc/at.allow")
        (regexp "^" (jinja "{{ item }}") "$")
        (line (jinja "{{ item }}"))
        (state "present")
        (create "True")
        (owner "root")
        (group "daemon")
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", atd_default_allow
                           + atd_allow
                           + atd_group_allow
                           + atd_host_allow) }}"))
      (when "(atd_enabled | bool and (atd_default_allow | d() or atd_allow | d() or atd_group_allow | d() or atd_host_allow | d()) and item | d())")
      (tags (list
          "role::atd:users")))
    (task "Remove /etc/at.allow if list is empty"
      (ansible.builtin.file 
        (path "/etc/at.allow")
        (state "absent"))
      (when "(atd_enabled | bool and (not atd_default_allow | d() and not atd_allow | d() and not atd_group_allow | d() and not atd_host_allow | d()))")
      (tags (list
          "role::atd:users")))
    (task "Configure /etc/at.deny"
      (ansible.builtin.lineinfile 
        (dest "/etc/at.deny")
        (regexp "^" (jinja "{{ item }}") "$")
        (line (jinja "{{ item }}"))
        (state "present")
        (create "True")
        (owner "root")
        (group "daemon")
        (mode "0640"))
      (loop (jinja "{{ q(\"flattened\", atd_default_deny
                           + atd_deny) }}"))
      (when "(atd_enabled | bool and (atd_default_deny | d() or atd_deny | d()) and item | d())")
      (tags (list
          "role::atd:users")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save atd facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/atd.fact.j2")
        (dest "/etc/ansible/facts.d/atd.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Gather Ansible facts if needed"
      (ansible.builtin.meta "flush_handlers"))))
