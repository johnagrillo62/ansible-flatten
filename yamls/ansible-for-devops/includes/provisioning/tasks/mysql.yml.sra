(playbook "ansible-for-devops/includes/provisioning/tasks/mysql.yml"
  (tasks
    (task "Create a MySQL database for Drupal."
      (mysql_db "db=" (jinja "{{ domain }}") " state=present"))
    (task "Create a MySQL user for Drupal."
      (mysql_user 
        (name (jinja "{{ domain }}"))
        (password "1234")
        (priv (jinja "{{ domain }}") ".*:ALL")
        (host "localhost")
        (state "present")))
    (task "Create a MySQL user for Drupal."
      (mysql_user 
        (name (jinja "{{ domain }}"))
        (password "1234")
        (priv (jinja "{{ domain }}") ".*:ALL")
        (host "localhost")
        (state "present")))))
