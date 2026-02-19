(playbook "ansible-examples/language_features/upgraded_vars.yml"
    (play
    (hosts "all")
    (vars
      (a_list (list
          "a"
          "b"
          "c")))
    (tasks
      (task
        (debug "msg=\"hello " (jinja "{{ ansible_hostname.upper() }}") "\""))
      (task
        (shell "echo match")
        (when "2 == 2"))
      (task
        (shell "echo no match")
        (when "2 == 2 + 1"))
      (task
        (debug "msg=\"" (jinja "{{ ansible_os_family }}") "\""))
      (task
        (shell "echo " (jinja "{{ item }}"))
        (with_items "a_list"))
      (task
        (shell "echo 'RedHat'")
        (when "ansible_os_family == 'RedHat'")))))
