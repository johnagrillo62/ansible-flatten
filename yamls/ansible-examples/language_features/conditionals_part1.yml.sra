(playbook "ansible-examples/language_features/conditionals_part1.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (vars_files (list
        "vars/external_vars.yml"
        (list
          "vars/" (jinja "{{ facter_operatingsystem }}") ".yml"
          "vars/defaults.yml")))
    (tasks
      (task "ensure apache is latest"
        (action (jinja "{{ packager }}") " pkg=" (jinja "{{ apache }}") " state=latest"))
      (task "ensure apache is running"
        (service "name=" (jinja "{{ apache }}") " state=running")))))
