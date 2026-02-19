(playbook "debops/ansible/roles/phpmyadmin/defaults/main.yml"
  (phpmyadmin_dependencies "True")
  (phpmyadmin_domain (list
      "mysql." (jinja "{{ ansible_domain }}")))
  (phpmyadmin_password_length "20")
  (phpmyadmin_control_password (jinja "{{ lookup('password', secret + '/mariadb/' + ansible_local['mariadb'].delegate_to + '/credentials/' + phpmyadmin_control_user + '/password length=' + phpmyadmin_password_length) }}"))
  (phpmyadmin_allow (list))
  (phpmyadmin_upload_size "64M")
  (phpmyadmin_php5_max_children "20")
  (phpmyadmin__php__dependent_packages (list
      "mysql"
      "mcrypt"
      "gd"))
  (phpmyadmin__php__dependent_pools (list
      (jinja "{{ phpmyadmin_php5_pool }}")))
  (phpmyadmin__nginx__dependent_servers (list
      (jinja "{{ phpmyadmin_nginx_server }}")))
  (phpmyadmin__nginx__dependent_upstreams (list
      (jinja "{{ phpmyadmin_nginx_upstream_php5 }}"))))
