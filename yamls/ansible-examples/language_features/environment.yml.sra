(playbook "ansible-examples/language_features/environment.yml"
    (play
    (hosts "all")
    (remote_user "root")
    (vars
      (env 
        (HI "test2")
        (http_proxy "http://proxy.example.com:8080")))
    (tasks
      (task
        (shell "echo $HI")
        (environment 
          (HI "test1")))
      (task
        (shell "echo $HI")
        (environment (jinja "{{ env }}"))))))
