(playbook "yaml/roles/mailserver/tasks/postfix.yml"
  (tasks
    (task "Install Postfix and related packages"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "libsasl2-modules"
          "postfix"
          "postfix-pcre"
          "postfix-pgsql"
          "postgrey"
          "python-psycopg2"
          "sasl2-bin"))
      (tags (list
          "dependencies")))
    (task "Create database user for mail server"
      (postgresql_user "login_host=localhost login_user=" (jinja "{{ db_admin_username }}") " login_password=\"" (jinja "{{ db_admin_password }}") "\" name=" (jinja "{{ mail_db_username }}") " password=\"" (jinja "{{ mail_db_password }}") "\" encrypted=yes state=present")
      (notify "import sql postfix"))
    (task "Create database for mail server"
      (postgresql_db "login_host=localhost login_user=" (jinja "{{ db_admin_username }}") " login_password=\"" (jinja "{{ db_admin_password }}") "\" name=" (jinja "{{ mail_db_database }}") " state=present owner=" (jinja "{{ mail_db_username }}"))
      (notify "import sql postfix"))
    (task "Copy import.sql"
      (template "src=mailserver.sql.j2 dest=/etc/postfix/import.sql owner=root group=root mode=0600")
      (notify "import sql postfix"))
    (task "Create postfix maps directory"
      (file "path=/etc/postfix/maps state=directory owner=root group=root")
      (when "mail_header_privacy == 1"))
    (task "Copy smtp_header_checks.pcre"
      (copy "src=etc_postfix_maps_smtp_header_checks.pcre dest=/etc/postfix/maps/smtp_header_checks.pcre owner=root group=root")
      (when "mail_header_privacy == 1"))
    (task "Copy main.cf"
      (template "src=etc_postfix_main.cf.j2 dest=/etc/postfix/main.cf owner=root group=root")
      (notify "restart postfix"))
    (task "Copy master.cf"
      (copy "src=etc_postfix_master.cf dest=/etc/postfix/master.cf owner=root group=root")
      (notify "restart postfix"))
    (task "Copy additional postfix configuration files"
      (template "src=etc_postfix_" (jinja "{{ item }}") ".j2 dest=/etc/postfix/" (jinja "{{ item }}") " owner=root group=root")
      (with_items (list
          "pgsql-virtual-alias-maps.cf"
          "pgsql-virtual-mailbox-domains.cf"
          "pgsql-virtual-mailbox-maps.cf"))
      (notify "restart postfix"))
    (task "Set firewall rules for postfix"
      (ufw "rule=allow port=" (jinja "{{ item }}") " proto=tcp")
      (with_items (list
          "smtp"
          "ssmtp"
          "submission"))
      (tags "ufw"))))
