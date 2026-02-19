(playbook "ansible-examples/windows/ping.yml"
    (play
    (name "Ping")
    (hosts "all")
    (tasks
      (task "ping"
        (win_ping null)))))
