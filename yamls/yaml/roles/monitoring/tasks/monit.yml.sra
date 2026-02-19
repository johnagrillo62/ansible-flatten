(playbook "yaml/roles/monitoring/tasks/monit.yml"
  (tasks
    (task "Add monitoring vhost to apache"
      (copy "src=etc_apache2_sites-available_00-status.conf dest=/etc/apache2/sites-available/00-status.conf"))
    (task "Enable the status vhost"
      (command "a2ensite 00-status.conf creates=/etc/apache2/sites-enabled/00-status.conf")
      (notify "restart apache"))
    (task "Install monit"
      (apt "pkg=monit state=present")
      (tags (list
          "dependencies")))
    (task "Copy monit master config file into place"
      (copy "src=etc_monit_monitrc dest=/etc/monit/monitrc")
      (notify "restart monit"))
    (task "Determine if ZNC is installed"
      (stat "path=/usr/lib/znc/configs/znc.conf")
      (register "znc_config_file"))
    (task "Copy ZNC monit service config files into place"
      (copy "src=etc_monit_conf.d_znc dest=/etc/monit/conf.d/znc")
      (notify "restart monit")
      (when "znc_config_file.stat.exists"))
    (task "Copy monit service config files into place"
      (copy "src=etc_monit_conf.d_" (jinja "{{ item }}") " dest=/etc/monit/conf.d/" (jinja "{{ item }}"))
      (with_items (list
          "apache2"
          "dovecot"
          "pgsql"
          "postfix"
          "sshd"
          "tomcat"))
      (notify "restart monit"))))
