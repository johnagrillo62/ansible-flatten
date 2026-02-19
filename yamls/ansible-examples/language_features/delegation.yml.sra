(playbook "ansible-examples/language_features/delegation.yml"
    (play
    (hosts "all")
    (serial "5")
    (tasks
      (task "take the machine out of rotation"
        (command "echo taking out of rotation " (jinja "{{inventory_hostname}}"))
        (delegate_to "127.0.0.1"))
      (task "do several things on the actual host"
        (command "echo hi mom " (jinja "{{inventory_hostname}}")))
      (task "put machine back into rotation"
        (command "echo inserting into rotation " (jinja "{{inventory_hostname}}"))
        (delegate_to "127.0.0.1")))))
