(playbook "debops/ansible/roles/mariadb_server/tasks/secure_installation.yml"
  (tasks
    (task "Delete anonymous database user"
      (community.mysql.mysql_user 
        (user "")
        (host (jinja "{{ item }}"))
        (state "absent")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (with_items (list
          (jinja "{{ ansible_hostname }}")
          "localhost")))
    (task "Remove test database on first install"
      (community.mysql.mysql_db 
        (db "test")
        (state "absent")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (when "((mariadb_server__register_version | d() and not mariadb_server__register_version.stdout) and (mariadb_server__register_install_status | d() and mariadb_server__register_install_status is changed))"))))
