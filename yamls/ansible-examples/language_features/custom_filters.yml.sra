(playbook "ansible-examples/language_features/custom_filters.yml"
    (play
    (name "Demonstrate custom jinja2 filters")
    (hosts "all")
    (tasks
      (task
        (template "src=templates/custom-filters.j2 dest=/tmp/custom-filters.txt")))))
