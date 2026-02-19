(playbook "debops/ansible/roles/phpmyadmin/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install dbconfig-common"
      (ansible.builtin.package 
        (name "dbconfig-common")
        (state "present"))
      (register "phpmyadmin__register_dbconfig_packages")
      (until "phpmyadmin__register_dbconfig_packages is succeeded"))
    (task "Pre-configure PHPMyAdmin database"
      (ansible.builtin.template 
        (src "etc/dbconfig-common/phpmyadmin.conf.j2")
        (dest "/etc/dbconfig-common/phpmyadmin.conf")
        (owner "root")
        (group "root")
        (mode "0600")))
    (task "Install PHPMyAdmin packages"
      (ansible.builtin.package 
        (name "phpmyadmin")
        (state "present"))
      (register "phpmyadmin__register_packages")
      (until "phpmyadmin__register_packages is succeeded"))
    (task "Create database for PHPMyAdmin"
      (community.mysql.mysql_db 
        (name (jinja "{{ phpmyadmin_control_database | default(\"phpmyadmin\") }}"))
        (state "present"))
      (register "phpmyadmin_database"))
    (task "Import PHPMyAdmin schema"
      (community.mysql.mysql_db 
        (name (jinja "{{ phpmyadmin_control_database | default(\"phpmyadmin\") }}"))
        (state "import")
        (target "/usr/share/dbconfig-common/data/phpmyadmin/install/mysql")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (when "phpmyadmin_database is defined and phpmyadmin_database is changed"))
    (task "Create PHPMyAdmin control user"
      (community.mysql.mysql_user 
        (name (jinja "{{ phpmyadmin_control_user | default('phpmyadmin') }}"))
        (state "present")
        (password (jinja "{{ phpmyadmin_control_password }}"))
        (priv (jinja "{{ phpmyadmin_control_database | default('phpmyadmin') }}") ".*:ALL")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (no_log (jinja "{{ debops__no_log | d(True) }}")))))
