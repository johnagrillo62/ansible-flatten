(playbook "ansible-for-devops/test-plugin/main.yml"
    (play
    (hosts "all")
    (vars
      (my_color_choice "blue"))
    (tasks
      (task "Verify " (jinja "{{ my_color_choice }}") " is a form of blue."
        (assert 
          (that "my_color_choice is blue"))))))
