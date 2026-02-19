(playbook "ansible-examples/language_features/roles/foo/handlers/main.yml"
  (tasks
    (task "blippy"
      (shell "echo notifier called, and the value of x is '" (jinja "{{ x }}") "'"))))
