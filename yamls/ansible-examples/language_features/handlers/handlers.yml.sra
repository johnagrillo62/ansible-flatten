(playbook "ansible-examples/language_features/handlers/handlers.yml"
  (tasks
    (task "restart apache"
      (service "name=httpd state=restarted"))
    (task "restart memcached"
      (service "name=memcached state=restarted"))))
