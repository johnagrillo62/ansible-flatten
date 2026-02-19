(playbook "ansible-examples/lamp_simple/roles/web/tasks/copy_code.yml"
  (tasks
    (task "Copy the code from repository"
      (git 
        (repo (jinja "{{ repository }}"))
        (dest "/var/www/html/")))
    (task "Creates the index.php file"
      (template 
        (src "index.php.j2")
        (dest "/var/www/html/index.php")))))
