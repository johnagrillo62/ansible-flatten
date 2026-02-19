(playbook "debops/ansible/roles/debconf/tasks/shell_commands.yml"
  (tasks
    (task (jinja "{{ item.name }}")
      (ansible.builtin.shell (jinja "{{ item.script | d(item.shell | d(item.command)) }}"))
      (args 
        (chdir (jinja "{{ item.chdir | d(omit) }}"))
        (creates (jinja "{{ item.creates | d(omit) }}"))
        (removes (jinja "{{ item.removes | d(omit) }}"))
        (executable (jinja "{{ item.executable | d(\"bash\") }}")))
      (when "item.name | d() and item.state not in ['absent', 'ignore']")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(False) }}"))
      (tags (list
          "role::late_tasks:commands")))))
