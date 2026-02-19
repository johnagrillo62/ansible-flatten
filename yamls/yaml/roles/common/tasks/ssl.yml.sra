(playbook "yaml/roles/common/tasks/ssl.yml"
  (tasks
    (task "Create strong Diffie-Hellman group"
      (command "openssl dhparam -out /etc/ssl/private/dhparam2048.pem 2048 creates=/etc/ssl/private/dhparam2048.pem"))
    (task "Enable Apache SSL module"
      (command "a2enmod ssl creates=/etc/apache2/mods-enabled/ssl.load")
      (notify "restart apache"))
    (task "Enable Apache SOCACHE_SHMCB module for the SSL stapling cache"
      (command "a2enmod socache_shmcb creates=/etc/apache2/mods-enabled/socache_shmcb.load")
      (notify "restart apache"))
    (task "Add common Apache SSL config"
      (template "src=etc_apache2_conf-available_ssl.conf.j2 dest=/etc/apache2/conf-available/ssl.conf owner=root group=root")
      (notify "restart apache"))
    (task "Enable Apache SSL config"
      (command "a2enconf ssl creates=/etc/apache2/conf-enabled/ssl.conf")
      (notify "restart apache"))))
