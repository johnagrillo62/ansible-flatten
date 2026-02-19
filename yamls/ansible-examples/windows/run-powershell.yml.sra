(playbook "ansible-examples/windows/run-powershell.yml"
    (play
    (name "Run powershell script")
    (hosts "all")
    (gather_facts "false")
    (tasks
      (task "Run powershell script"
        (script "files/helloworld.ps1")))))
