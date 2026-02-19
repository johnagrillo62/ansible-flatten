(playbook "ansible-examples/lamp_haproxy/aws/roles/web/tasks/main.yml"
  (tasks
    (task "Copy the code from repository"
      (git 
        (repo (jinja "{{ repository }}"))
        (version (jinja "{{ webapp_version }}"))
        (dest "/var/www/html/")))))
