(playbook "yaml/roles/news/tasks/selfoss.yml"
  (tasks
    (task "Clone Selfoss"
      (git "repo=https://github.com/SSilence/selfoss.git dest=/var/www/selfoss accept_hostkey=yes version=" (jinja "{{ selfoss_version }}")))
    (task "Set selfoss ownership"
      (action "file owner=root group=www-data path=/var/www/selfoss recurse=yes state=directory"))
    (task "Set selfoss permission"
      (action "file path=/var/www/selfoss/" (jinja "{{ item }}") " mode=0775")
      (with_items (list
          "data/cache"
          "data/favicons"
          "data/logs"
          "data/thumbnails"
          "data/sqlite"
          "public")))
    (task "Install selfoss dependencies"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "php5"
          "php5-pgsql"
          "php5-gd"))
      (tags (list
          "dependencies")))
    (task "Create database user for selfoss"
      (postgresql_user "login_host=localhost login_user=" (jinja "{{ db_admin_username }}") " login_password=\"" (jinja "{{ db_admin_password }}") "\" name=" (jinja "{{ selfoss_db_username }}") " password=\"" (jinja "{{ selfoss_db_password }}") "\" state=present"))
    (task "Create database for selfoss"
      (postgresql_db "login_host=localhost login_user=" (jinja "{{ db_admin_username }}") " login_password=\"" (jinja "{{ db_admin_password }}") "\" name=" (jinja "{{ selfoss_db_database }}") " state=present owner=" (jinja "{{ selfoss_db_username }}")))
    (task "Install selfoss config.ini"
      (template "src=var_www_selfoss_config.ini.j2 dest=/var/www/selfoss/config.ini group=www-data owner=root mode=0640"))
    (task "Enable Apache rewrite module"
      (command "a2enmod rewrite creates=/etc/apache2/mods-enabled/rewrite.load")
      (notify "restart apache"))
    (task "Enable Apache headers module"
      (command "a2enmod headers creates=/etc/apache2/mods-enabled/headers.load")
      (notify "restart apache"))
    (task "Enable Apache expires module"
      (command "a2enmod expires creates=/etc/apache2/mods-enabled/expires.load")
      (notify "restart apache"))
    (task "Rename existing Apache blog virtualhost"
      (command "mv /etc/apache2/sites-available/selfoss /etc/apache2/sites-available/selfoss.conf removes=/etc/apache2/sites-available/selfoss"))
    (task "Remove old sites-enabled/selfoss symlink (new one will be created by a2ensite)"
      (file "path=/etc/apache2/sites-enabled/selfoss state=absent"))
    (task "Configure the Apache HTTP server for selfoss"
      (template "src=etc_apache2_sites-available_selfoss.j2 dest=/etc/apache2/sites-available/selfoss.conf group=root owner=root"))
    (task "Enable the selfoss site"
      (command "a2ensite selfoss.conf creates=/etc/apache2/sites-enabled/selfoss.conf")
      (notify "restart apache"))
    (task "Install selfoss cronjob"
      (cron "name=\"selfoss\" user=\"www-data\" minute=\"*/5\" job=\"curl --silent --show-error -k 'https://" (jinja "{{ selfoss_domain }}") "/update' > /dev/null\""))
    (task "Configure selfoss logrotate"
      (copy "src=etc_logrotate_selfoss dest=/etc/logrotate.d/selfoss owner=root group=root mode=0644"))))
