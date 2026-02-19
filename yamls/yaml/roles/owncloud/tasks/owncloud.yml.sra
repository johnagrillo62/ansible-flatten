(playbook "yaml/roles/owncloud/tasks/owncloud.yml"
  (tasks
    (task "Install ownCloud dependencies"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "postgresql"
          "python-psycopg2"))
      (tags (list
          "dependencies")))
    (task "Set password for PostgreSQL admin user"
      (postgresql_user "name=" (jinja "{{ db_admin_username }}") " password=" (jinja "{{ db_admin_password }}") " encrypted=yes")
      (become "true")
      (become_user "postgres"))
    (task "Create database user for ownCloud"
      (postgresql_user "login_host=localhost login_user=" (jinja "{{ db_admin_username }}") " login_password=\"" (jinja "{{ db_admin_password }}") "\" name=" (jinja "{{ owncloud_db_username }}") " password=\"" (jinja "{{ owncloud_db_password }}") "\" role_attr_flags=CREATEDB state=present"))
    (task "Ensure repository key for ownCloud is in place"
      (apt_key "url=https://download.owncloud.org/download/repositories/stable/Debian_8.0/Release.key state=present")
      (tags (list
          "dependencies")))
    (task "Add ownCloud repository"
      (apt_repository "repo='deb http://download.owncloud.org/download/repositories/stable/Debian_8.0/ /'")
      (tags (list
          "dependencies")))
    (task "Install ownCloud"
      (apt "pkg=owncloud-files update_cache=yes")
      (tags (list
          "dependencies")))
    (task "Ensure ownCloud directory is in place"
      (file "state=directory path=/var/www/owncloud"))
    (task "Move ownCloud data to encrypted filesystem"
      (command "mv /var/www/owncloud/data /decrypted/owncloud-data creates=/decrypted/owncloud-data"))
    (task "Link ownCloud data directory to encrypted filesystem"
      (file "src=/decrypted/owncloud-data dest=/var/www/owncloud/data owner=www-data group=www-data state=link"))
    (task "Configure Apache for ownCloud"
      (template "src=etc_apache2_sites-available_owncloud.j2 dest=/etc/apache2/sites-available/owncloud.conf group=root")
      (notify "restart apache"))
    (task "Enable ownCloud site"
      (command "a2ensite owncloud.conf creates=/etc/apache2/sites-enabled/owncloud.conf")
      (notify "restart apache"))
    (task "Install ownCloud cronjob"
      (cron "name=\"ownCloud\" user=\"www-data\" minute=\"*/5\" job=\"php -f /var/www/owncloud/cron.php > /dev/null\""))))
