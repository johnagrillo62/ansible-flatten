(playbook "yaml/roles/readlater/tasks/wallabag.yml"
  (tasks
    (task "Determine whether wallabag is configured"
      (stat "path=/var/www/wallabag/inc/poche/config.inc.php")
      (register "wallabag_config"))
    (task "Clone wallabag"
      (git "repo=https://github.com/wallabag/wallabag.git dest=/var/www/wallabag version=" (jinja "{{ wallabag_version }}") " accept_hostkey=yes"))
    (task "Remove wallabag 'install' directory if its configuration file is there"
      (file "name=/var/www/wallabag/install state=absent")
      (when "wallabag_config.stat.exists"))
    (task "Install wallabag dependencies"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "php5"
          "php5-curl"
          "php5-mcrypt"
          "php5-pgsql"
          "php5-tidy"))
      (tags (list
          "dependencies")))
    (task "Create database user for wallabag"
      (postgresql_user "login_host=localhost login_user=" (jinja "{{ db_admin_username }}") " login_password=\"" (jinja "{{ db_admin_password }}") "\" name=" (jinja "{{ wallabag_db_username }}") " password=\"" (jinja "{{ wallabag_db_password }}") "\" state=present"))
    (task "Create database for wallabag"
      (postgresql_db "login_host=localhost login_user=" (jinja "{{ db_admin_username }}") " login_password=\"" (jinja "{{ db_admin_password }}") "\" name=" (jinja "{{ wallabag_db_database }}") " state=present owner=" (jinja "{{ wallabag_db_username }}"))
      (notify "import wallabag sql"))
    (task "Get Composer installer"
      (get_url "url=https://getcomposer.org/installer dest=/tmp/composer-installer"))
    (task "Install Composer"
      (command "php /tmp/composer-installer chdir=/root creates=/root/composer.phar"))
    (task "Initialize composer"
      (command "php /root/composer.phar install chdir=/var/www/wallabag creates=/var/www/wallabag/vendor/autoload.php"))
    (task "Set wallabag ownership"
      (file "owner=root group=www-data path=/var/www/wallabag recurse=yes state=directory"))
    (task "Set wallabag assets, cache and db permissions"
      (file "path=/var/www/wallabag/" (jinja "{{ item }}") " mode=0775 state=directory")
      (with_items (list
          "assets"
          "cache"
          "db")))
    (task "Create the configuration file"
      (template "src=var_www_wallabag_inc_poche_config.inc.php.j2 dest=/var/www/wallabag/inc/poche/config.inc.php owner=root group=www-data"))
    (task "Rename existing Apache wallabag virtualhost"
      (command "mv /etc/apache2/sites-available/wallabag /etc/apache2/sites-available/wallabag.conf removes=/etc/apache2/sites-available/wallabag"))
    (task "Remove old sites-enabled/wallabag symlink (new one will be created by a2ensite)"
      (file "path=/etc/apache2/sites-enabled/wallabag state=absent"))
    (task "Configure the Apache HTTP server for wallabag"
      (template "src=etc_apache2_sites-available_wallabag.j2 dest=/etc/apache2/sites-available/wallabag.conf owner=root group=root"))
    (task "Enable the wallabag site"
      (command "a2ensite wallabag.conf creates=/etc/apache2/sites-enabled/wallabag.conf")
      (notify "restart apache"))))
