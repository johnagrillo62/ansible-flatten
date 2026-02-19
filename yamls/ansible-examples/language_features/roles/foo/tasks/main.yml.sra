(playbook "ansible-examples/language_features/roles/foo/tasks/main.yml"
  (tasks
    (task "copy operation"
      (copy "src=foo.txt dest=/tmp/roles_test1.txt"))
    (task "template operation"
      (template "src=foo.j2 dest=/tmp/roles_test2.txt")
      (notify (list
          "blippy")))
    (task "demo that parameterized roles work"
      (shell "echo just FYI, param1=" (jinja "{{ param1 }}") ", param2 =" (jinja "{{ param2 }}")))))
