(playbook "ansible-examples/rust-module-hello-world/rust.yml"
    (play
    (hosts "localhost")
    (tasks
      (task
        (debug 
          (msg "Testing a binary module written in Rust")))
      (task
        (debug 
          (var "ansible_system")))
      (task "ping"
        (ping null))
      (task "Hello, World!"
        (rust_helloworld null)
        (register "hello_world"))
      (task
        (assert 
          (that (list
              "hello_world.msg == \"Hello, World!\"
"))))
      (task "Hello, Ansible!"
        (rust_helloworld 
          (name "Ansible"))
        (register "hello_ansible"))
      (task
        (assert 
          (that (list
              "hello_ansible.msg == \"Hello, Ansible!\"
"))))
      (task "Async Hello, World!"
        (rust_helloworld null)
        (async "10")
        (poll "1")
        (register "async_hello_world"))
      (task
        (assert 
          (that (list
              "async_hello_world.msg == \"Hello, World!\"
"))))
      (task "Async Hello, Ansible!"
        (rust_helloworld 
          (name "Ansible"))
        (async "10")
        (poll "1")
        (register "async_hello_ansible"))
      (task
        (assert 
          (that (list
              "async_hello_ansible.msg == \"Hello, Ansible!\"")))))))
