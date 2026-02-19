(playbook "debops/ansible/roles/ifupdown/handlers/main.yml"
  (tasks
    (task "Apply ifupdown configuration"
      (ansible.builtin.script "script/ifupdown-reconfigure-interfaces")
      (environment 
        (LC_ALL "C"))
      (when "ifupdown__reconfigure_auto | bool"))))
