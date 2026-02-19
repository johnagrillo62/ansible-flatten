(playbook "ansible-examples/language_features/tags.yml"
    (play
    (name "example play one")
    (hosts "all")
    (remote_user "root")
    (tags (list
        "extra"))
    (tasks
      (task "hi"
        (shell "echo \"first task ran\"")
        (tags (list
            "foo")))))
    (play
    (name "example play two")
    (hosts "all")
    (remote_user "root")
    (tasks
      (task "hi"
        (shell "echo \"second task ran\"")
        (tags (list
            "bar")))
      (task
        (include "tasks/base.yml")
        (tags (list
            "base"))))))
