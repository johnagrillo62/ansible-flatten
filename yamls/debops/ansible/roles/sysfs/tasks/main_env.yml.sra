(playbook "debops/ansible/roles/sysfs/tasks/main_env.yml"
  (tasks
    (task "Prepare sysfs environment"
      (ansible.builtin.set_fact 
        (sysfs__secret__directories (jinja "{{ lookup(\"template\", \"lookup/sysfs__secret__directories.j2\") | from_yaml }}")))
      (when "sysfs__enabled | bool"))))
