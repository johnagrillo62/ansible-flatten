(playbook "yaml/roles/mailserver/handlers/main.yml"
  (tasks
    (task "restart postfix"
      (service "name=postfix state=restarted"))
    (task "restart dovecot"
      (service "name=dovecot state=restarted"))
    (task "restart opendkim"
      (service "name=opendkim state=restarted"))
    (task "restart solr"
      (service "name=tomcat7 state=restarted"))
    (task "import sql postfix"
      (command "psql -h localhost -d " (jinja "{{ mail_db_database }}") " -U " (jinja "{{ mail_db_username }}") " -f /etc/postfix/import.sql --set ON_ERROR_STOP=1")
      (environment 
        (PGPASSWORD (jinja "{{ mail_db_password }}")))
      (notify "restart postfix"))
    (task "restart rspamd"
      (service "name=rspamd state=restarted"))))
