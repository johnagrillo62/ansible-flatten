(playbook "yaml/roles/mailserver/tasks/dovecot.yml"
  (tasks
    (task "Install Dovecot and related packages"
      (apt "pkg=" (jinja "{{ item }}") " update_cache=yes state=present")
      (with_items (list
          "dovecot-core"
          "dovecot-imapd"
          "dovecot-lmtpd"
          "dovecot-managesieved"
          "dovecot-pgsql"
          "dovecot-pop3d"
          "dovecot-antispam"))
      (tags (list
          "dependencies")))
    (task "Install Postgres for Dovecot"
      (apt "pkg=postgresql state=present")
      (tags (list
          "dependencies")))
    (task "Create vmail group"
      (group "name=vmail state=present gid=5000"))
    (task "Create vmail user"
      (user "name=vmail group=vmail state=present uid=5000 home=/decrypted shell=/usr/sbin/nologin"))
    (task "Ensure mail domain directories are in place"
      (file "state=directory path=/decrypted/" (jinja "{{ item.name }}") " owner=vmail group=dovecot mode=0770")
      (with_items (jinja "{{ mail_virtual_domains }}")))
    (task "Ensure mail directories are in place"
      (file "state=directory path=/decrypted/" (jinja "{{ item.domain }}") "/" (jinja "{{ item.account }}") " owner=vmail group=dovecot")
      (with_items (jinja "{{ mail_virtual_users }}")))
    (task "Copy dovecot.conf into place"
      (copy "src=etc_dovecot_dovecot.conf dest=/etc/dovecot/dovecot.conf"))
    (task "Create before.d sieve scripts directory"
      (file "path=/etc/dovecot/sieve/before.d state=directory owner=vmail group=dovecot recurse=yes mode=0770")
      (notify "restart dovecot"))
    (task "Configure sieve script moving spam into Junk folder"
      (copy "src=etc_dovecot_sieve_before.d_no-spam.sieve dest=/etc/dovecot/sieve/before.d/no-spam.sieve owner=vmail group=dovecot")
      (notify "restart dovecot"))
    (task "Copy additional Dovecot configuration files in place"
      (copy "src=etc_dovecot_conf.d_" (jinja "{{ item }}") " dest=/etc/dovecot/conf.d/" (jinja "{{ item }}"))
      (with_items (list
          "10-auth.conf"
          "10-mail.conf"
          "10-master.conf"
          "90-antispam.conf"
          "90-plugin.conf"
          "90-sieve.conf"
          "auth-sql.conf.ext"))
      (notify "restart dovecot"))
    (task "Template 10-ssl.conf"
      (template "src=etc_dovecot_conf.d_10-ssl.conf.j2 dest=/etc/dovecot/conf.d/10-ssl.conf")
      (notify "restart dovecot"))
    (task "Template 15-lda.conf"
      (template "src=etc_dovecot_conf.d_15-lda.conf.j2 dest=/etc/dovecot/conf.d/15-lda.conf")
      (notify "restart dovecot"))
    (task "Template 20-imap.conf"
      (template "src=etc_dovecot_conf.d_20-imap.conf.j2 dest=/etc/dovecot/conf.d/20-imap.conf")
      (notify "restart dovecot"))
    (task "Template dovecot-sql.conf.ext"
      (template "src=etc_dovecot_dovecot-sql.conf.ext.j2 dest=/etc/dovecot/dovecot-sql.conf.ext")
      (notify "restart dovecot"))
    (task "Ensure correct permissions on Dovecot config directory"
      (file "state=directory path=/etc/dovecot group=dovecot owner=vmail mode=0770 recurse=yes")
      (notify "restart dovecot"))
    (task "Set firewall rules for dovecot"
      (ufw "rule=allow port=" (jinja "{{ item }}") " proto=tcp")
      (with_items (list
          "imaps"
          "pop3s"))
      (tags "ufw"))
    (task "Update post-certificate-renewal task"
      (copy 
        (content "#!/bin/bash

service dovecot restart
")
        (dest "/etc/letsencrypt/postrenew/dovecot.sh")
        (mode "0755")
        (owner "root")
        (group "root")))))
