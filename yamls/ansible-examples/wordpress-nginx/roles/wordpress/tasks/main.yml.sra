(playbook "ansible-examples/wordpress-nginx/roles/wordpress/tasks/main.yml"
  (tasks
    (task "Download WordPress"
      (get_url "url=http://wordpress.org/wordpress-" (jinja "{{ wp_version }}") ".tar.gz dest=/srv/wordpress-" (jinja "{{ wp_version }}") ".tar.gz sha256sum=\"" (jinja "{{ wp_sha256sum }}") "\""))
    (task "Extract archive"
      (unarchive 
        (creates "/srv/wordpress")
        (src "/srv/wordpress-" (jinja "{{ wp_version }}") ".tar.gz")
        (dest "/srv/wordpress")))
    (task "Add group \"wordpress\""
      (group "name=wordpress"))
    (task "Add user \"wordpress\""
      (user "name=wordpress group=wordpress home=/srv/wordpress/"))
    (task "Fetch random salts for WordPress config"
      (get_url 
        (url "https://api.wordpress.org/secret-key/1.1/salt/"))
      (register "wp_salt")
      (become "no")
      (become_method "sudo")
      (changed_when "true")
      (delegate_to "localhost"))
    (task "Create WordPress database"
      (mysql_db "name=" (jinja "{{ wp_db_name }}") " state=present"))
    (task "Create WordPress database user"
      (mysql_user "name=" (jinja "{{ wp_db_user }}") " password=" (jinja "{{ wp_db_password }}") " priv=" (jinja "{{ wp_db_name }}") ".*:ALL host='localhost' state=present"))
    (task "Copy WordPress config file"
      (template "src=wp-config.php dest=/srv/wordpress/"))
    (task "Change ownership of WordPress installation"
      (file "path=/srv/wordpress/ owner=wordpress group=wordpress state=directory recurse=yes setype=httpd_sys_content_t"))
    (task "Start php-fpm Service"
      (service "name=php-fpm state=started enabled=yes"))))
