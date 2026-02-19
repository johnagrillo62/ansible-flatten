(playbook "awx/main/tests/data/ansible_utils/playbooks/valid/hello_world.yaml"
    (play
    (name "Hello World Sample")
    (hosts "all")
    (tasks
      (task "Hello Message"
        (debug 
          (msg "Hello World!"))))))
