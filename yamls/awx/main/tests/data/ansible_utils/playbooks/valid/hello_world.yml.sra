(playbook "awx/main/tests/data/ansible_utils/playbooks/valid/hello_world.yml"
    (play
    (name "Hello World Sample")
    (hosts "all")
    (tasks
      (task "Hello Message"
        (ansible.builtin.debug 
          (msg "Hello World!"))))))
