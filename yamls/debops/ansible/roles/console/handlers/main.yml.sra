(playbook "debops/ansible/roles/console/handlers/main.yml"
  (tasks
    (task "Reload sysvinit"
      (ansible.builtin.command "telinit q")
      (register "console__register_telinit")
      (changed_when "console__register_telinit.changed | bool"))))
