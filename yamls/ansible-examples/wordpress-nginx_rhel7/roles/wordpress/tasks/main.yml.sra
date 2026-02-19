(playbook "ansible-examples/wordpress-nginx_rhel7/roles/wordpress/tasks/main.yml"
  (tasks
    (task "Download WordPress"
      (get_url "url=http://wordpress.org/wordpress-" (jinja "{{ wp_version }}") ".tar.gz dest=/srv/wordpress-" (jinja "{{ wp_version }}") ".tar.gz sha256sum=\"" (jinja "{{ wp_sha256sum }}") "\""))
    (task "Extract archive"
      (command "chdir=/srv/ /bin/tar xvf wordpress-" (jinja "{{ wp_version }}") ".tar.gz creates=/srv/wordpress"))
    (task "Add group \"wordpress\""
      (group "name=wordpress"))
    (task "Add user \"wordpress\""
      (user "name=wordpress group=wordpress home=/srv/wordpress/"))
    (task "Fetch random salts for WordPress config"
      (local_action "command curl https://api.wordpress.org/secret-key/1.1/salt/")
      (register "wp_salt")
      (become "no"))
    (task "Create WordPress database"
      (mysql_db "name=" (jinja "{{ wp_db_name }}") " state=present"))
    (task "Create WordPress database user"
      (mysql_user "name=" (jinja "{{ wp_db_user }}") " password=" (jinja "{{ wp_db_password }}") " priv=" (jinja "{{ wp_db_name }}") ".*:ALL host='localhost' state=present"))
    (task "Copy WordPress config file"
      (template "src=wp-config.php dest=/srv/wordpress/"))
    (task "Change ownership of WordPress installation"
      (file "path=/srv/wordpress/ owner=wordpress group=wordpress state=directory recurse=yes"))
    (task "install SEManage"
      (yum "pkg=policycoreutils-python state=present"))
    (task "set the SELinux policy for the Wordpress directory"
      (command "semanage fcontext -a -t httpd_sys_content_t \"/srv/wordpress(/.*)?\""))
    (task "set the SELinux policy for wp-config.php"
      (command "semanage fcontext -a -t httpd_sys_script_exec_t \"/srv/wordpress/wp-config\\.php\""))
    (task "set the SELinux policy for wp-content directory"
      (command "semanage fcontext -a -t httpd_sys_rw_content_t \"/srv/wordpress/wp-content(/.*)?\""))
    (task "set the SELinux policy for the *.php files"
      (command "semanage fcontext -a -t httpd_sys_script_exec_t \"/srv/wordpress/.*\\.php\""))
    (task "set the SELinux policy for the Upgrade directory"
      (command "semanage fcontext -a -t httpd_sys_rw_content_t \"/srv/wordpress/wp-content/upgrade(/.*)?\""))
    (task "set the SELinux policy for the Uploads directory"
      (command "semanage fcontext -a -t httpd_sys_rw_content_t \"/srv/wordpress/wp-content/uploads(/.*)?\""))
    (task "set the SELinux policy for the wp-includes php files"
      (command "semanage fcontext -a -t httpd_sys_script_exec_t \"/srv/wordpress/wp-includes/.*\\.php\""))
    (task "set the SELinux on all the Files"
      (command "restorecon -Rv /srv/wordpress"))
    (task "Start php-fpm Service"
      (service "name=php-fpm state=started enabled=yes"))))
