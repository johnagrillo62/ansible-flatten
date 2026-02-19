(playbook "ansible-examples/language_features/rabbitmq.yml"
    (play
    (hosts "rabbitmq")
    (become "true")
    (become_method "sudo")
    (vars
      (rabbitmq_version "3.0.2-1"))
    (tasks
      (task "ensure python-software-properties is installed"
        (apt "pkg=python-software-properties state=installed"))
      (task "add rabbitmq official apt repository"
        (apt_repository "repo='deb http://www.rabbitmq.com/debian/ testing main' state=present"))
      (task "add trusted key"
        (apt_key "url=https://www.rabbitmq.com/rabbitmq-signing-key-public.asc state=present"))
      (task "install package"
        (apt "name=" (jinja "{{ item }}") " update_cache=yes state=installed")
        (with_items (list
            "rabbitmq-server")))
      (task "enable rabbitmq plugins"
        (rabbitmq_plugin "names=rabbitmq_management,rabbitmq_tracing,rabbitmq_federation state=enabled")
        (notify (list
            "restart rabbitmq")))
      (task "add users"
        (rabbitmq_user "user=" (jinja "{{item.username}}") " password=" (jinja "{{item.password}}") " tags=administrator," (jinja "{{item.username}}") " vhost=/ configure_priv=.* write_priv=.* read_priv=.* state=present")
        (with_items (list
            
            (username "user1")
            (password "changeme")
            
            (username "user2")
            (password "changeme"))))
      (task "remove default guest user"
        (rabbitmq_user "user=guest state=absent"))
      (task "ensure vhost /test is present"
        (rabbitmq_vhost "name=/test state=present")))
    (handlers
      (task "restart rabbitmq"
        (service "name=rabbitmq-server state=restarted")))))
