(playbook "debops/ansible/roles/global_handlers/handlers/sshd.yml"
  (tasks
    (task "Test sshd configuration and restart"
      (ansible.builtin.command "sshd -t")
      (register "global_handlers__sshd_register_test_config")
      (changed_when "global_handlers__sshd_register_test_config.changed | bool")
      (notify (list
          "Restart sshd")))
    (task "Restart sshd"
      (ansible.builtin.service 
        (name "ssh")
        (state "restarted"))
      (when "(ansible_local.sshd.socket_activation | d('disabled')) == 'disabled'"))))
