(playbook "yaml/roles/common/tasks/apache.yml"
  (tasks
    (task "Disable default Apache site"
      (command "a2dissite 000-default removes=/etc/apache2/sites-enabled/000-default")
      (notify "restart apache"))
    (task "Enable Apache headers module"
      (command "a2enmod headers creates=/etc/apache2/mods-enabled/headers.load")
      (notify "restart apache"))
    (task "Create ServerName configuration file for Apache"
      (template "src=fqdn.j2 dest=/etc/apache2/conf-available/fqdn.conf"))
    (task "Set ServerName for Apache"
      (command "a2enconf fqdn creates=/etc/apache2/conf-enabled/fqdn.conf")
      (notify "restart apache"))))
