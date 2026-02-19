(playbook "ansible-for-devops/collection/main.yml"
    (play
    (hosts "all")
    (vars
      (my_color_choice "blue"))
    (tasks
      (task "Verify " (jinja "{{ my_color_choice }}") " is a form of blue."
        (assert 
          (that "my_color_choice is local.colors.blue")))
      (task "Verify yellow is not a form of blue."
        (assert 
          (that "'yellow' is not local.colors.blue"))))))
