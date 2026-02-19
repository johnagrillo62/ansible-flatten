(playbook "ansible-examples/language_features/batch_size_control.yml"
    (play
    (hosts "all")
    (serial "3")
    (tasks
      (task "ping"
        (ping null))
      (task "ping2"
        (ping null)))))
