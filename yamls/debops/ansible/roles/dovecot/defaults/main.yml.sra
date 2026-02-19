(playbook "debops/ansible/roles/dovecot/defaults/main.yml"
  (dovecot__features (list
      "imap"
      "imaps"
      "lmtp"
      "sieve"
      "quota"))
  (dovecot__auth_mechanisms (list
      "plain"
      "login"))
  (dovecot__version (jinja "{{ ansible_local.dovecot.version | d(\"0.0.0\") }}"))
  (dovecot__user_accounts (jinja "{{ [\"deny\", \"ldap\"]
                            if dovecot__ldap_enabled | bool
                            else [\"deny\", \"system\"] }}"))
  (dovecot__deny_users (list
      "root"))
  (dovecot__mail_location "maildir:~/Maildir")
  (dovecot__auth_default_realm (jinja "{{ ansible_domain }}"))
  (dovecot__vmail_enabled (jinja "{{ True if (dovecot__user_accounts |
                                     intersect([\"mysql\", \"pgsql\", \"sqlite\",
                                                \"ldap\", \"passwdfile\"]))
                            else False }}"))
  (dovecot__vmail_posix_user (jinja "{{ ansible_local.postldap.vmail_posix_user
                               | d(\"vmail\") }}"))
  (dovecot__vmail_posix_group (jinja "{{ ansible_local.postldap.vmail_posix_group
                                | d(\"vmail\") }}"))
  (dovecot__vmail_base "/var/vmail")
  (dovecot__vmail_home (jinja "{{ dovecot__vmail_base ~ \"/%d/%n\" }}"))
  (dovecot__dsync_port "12345")
  (dovecot__dsync_host "")
  (dovecot__dsync_replica (jinja "{{ (\"tcps\" if dovecot__pki | d(True) else \"tcp\") ~ \":\" ~
                            dovecot__dsync_host ~ \":\" ~
                            dovecot__dsync_port }}"))
  (dovecot__dsync_password_path (jinja "{{ \"dovecot/credentials/dsync.password\" }}"))
  (dovecot__dsync_password (jinja "{{ lookup(\"password\", secret + \"/\"
                                    + dovecot__dsync_password_path
                                    + \" length=32\") }}"))
  (dovecot__sql_connect "")
  (dovecot__sql_default_pass_scheme "SSHA512")
  (dovecot__sql_password_query "SELECT userid AS username, domain, password FROM users WHERE userid = '%n' AND domain = '%d'")
  (dovecot__sql_user_query "SELECT home, uid, gid FROM users WHERE userid = '%n' AND domain = '%d'")
  (dovecot__sql_iterate_query "SELECT userid AS username, domain FROM users")
  (dovecot__passwdfile_scheme "sha512-crypt")
  (dovecot__passwdfile_path "/etc/dovecot/private/")
  (dovecot__passwdfile_name "passwd")
  (dovecot__checkpassword_passdb_command "/usr/bin/checkpassword")
  (dovecot__checkpassword_userdb_command "/usr/bin/checkpassword")
  (dovecot__pki (jinja "{{ ansible_local.pki.enabled | d() | bool }}"))
  (dovecot__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (dovecot__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (dovecot__pki_ca (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (dovecot__pki_crt (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (dovecot__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (dovecot__tls_ca_cert_dir "/etc/ssl/certs/")
  (dovecot__ssl_required "True")
  (dovecot__ssl_min_protocol (jinja "{{ \"TLSv1.2\" }}"))
  (dovecot__ssl_dh_parameters_length "4096")
  (dovecot__ssl_cipher_list (jinja "{{ dovecot__ssl_cipher_list_default }}"))
  (dovecot__ssl_cipher_list_default "ALL:!kRSA:!SRP:!kDHd:!DSS:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK:!RC4:!ADH:!LOW@STRENGTH")
  (dovecot__ssl_cipher_list_better_crypto "EDH+CAMELLIA:EDH+aRSA:EECDH+aRSA+AESGCM:EECDH+aRSA+SHA256:EECDH:+CAMELLIA128:+AES128:+SSLv3:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!DSS:!RC4:!SEED:!IDEA:!ECDSA:kEDH:CAMELLIA128-SHA:AES128-SHA")
  (dovecot__ssl_cipher_list_ncsc_nl "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256")
  (dovecot__pki_hook_name "dovecot")
  (dovecot__pki_hook_path (jinja "{{ ansible_local.pki.hooks | d(\"/etc/pki/hooks\") }}"))
  (dovecot__pki_hook_action "reload")
  (dovecot__dhparam (jinja "{{ ansible_local.dhparam.enabled
                      if (ansible_local | d() and ansible_local.dhparam | d() and
                          ansible_local.dhparam.enabled is defined)
                      else False }}"))
  (dovecot__dhparam_set "default")
  (dovecot__ssl_dh_file (jinja "{{ ansible_local.dhparam[dovecot__dhparam_set]
                          if (ansible_local | d() and ansible_local.dhparam | d() and
                            ansible_local.dhparam[dovecot__dhparam_set] | d())
                          else \"\" }}"))
  (dovecot__default_configuration (list
      
      (section "main")
      (title "Main Configuration")
      (options (list
          
          (name "protocols")
          (comment "Currently active protocols")
          (value (jinja "{{ dovecot__features |
             intersect(['imap', 'imaps', 'pop3',
                        'pop3s', 'sieve', 'lmtp']) |
             map(\"regex_replace\", \"^(imap|pop3)s$\", \"\\1\") |
             list | unique | join(' ') }}") "
")))
      
      (section "authentication")
      (title "Client Configuration")
      (options (list
          
          (name "auth_mechanisms")
          (value (jinja "{{ dovecot__auth_mechanisms | join(\" \") }}"))
          
          (name "disable_plaintext_auth")
          (value "yes")
          
          (name "auth_default_realm")
          (value (jinja "{{ dovecot__auth_default_realm }}"))
          
          (name "mail_uid")
          (value (jinja "{{ dovecot__vmail_posix_user }}"))
          (state (jinja "{{ \"present\" if dovecot__vmail_enabled | d(False) else \"absent\" }}"))
          
          (name "mail_gid")
          (value (jinja "{{ dovecot__vmail_posix_group }}"))
          (state (jinja "{{ \"present\" if dovecot__vmail_enabled | d(False) else \"absent\" }}"))
          
          (name "mail_privileged_group")
          (value (jinja "{{ dovecot__vmail_posix_user }}"))
          (state (jinja "{{ \"present\" if dovecot__vmail_enabled | d(False) else \"absent\" }}"))
          
          (name "passdb_deny")
          (option "passdb")
          (state (jinja "{{ \"present\" if \"deny\" in dovecot__user_accounts else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "passwd-file")
              
              (name "deny")
              (value "yes")
              
              (name "args")
              (value "/etc/dovecot/dovecot.deny")))
          
          (name "passdb_system")
          (option "passdb")
          (state (jinja "{{ \"present\" if \"system\" in dovecot__user_accounts else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "pam")
              
              (name "args")
              (value "session=yes dovecot")))
          
          (name "userdb_system")
          (option "userdb")
          (state (jinja "{{ \"present\" if \"system\" in dovecot__user_accounts else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "passwd")
              
              (name "args")
              (value "blocking=no")))
          
          (name "passdb_sql")
          (option "passdb")
          (state (jinja "{{ \"present\" if (dovecot__user_accounts | d([]) |
                     intersect([\"mysql\", \"pgsql\", \"sqlite\"])) else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "sql")
              
              (name "args")
              (value "/etc/dovecot/dovecot-sql.conf.ext")))
          
          (name "userdb_sql")
          (option "userdb")
          (state (jinja "{{ \"present\" if (dovecot__user_accounts | d([]) |
                     intersect([\"mysql\", \"pgsql\", \"sqlite\"])) else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "sql")
              
              (name "args")
              (value "/etc/dovecot/dovecot-sql.conf.ext")))
          
          (name "passdb_ldap")
          (option "passdb")
          (state (jinja "{{ \"present\" if \"ldap\" in dovecot__user_accounts else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "ldap")
              
              (name "args")
              (value "/etc/dovecot/dovecot-ldap-passdb.conf")))
          
          (name "userdb_ldap")
          (option "userdb")
          (state (jinja "{{ \"present\" if \"ldap\" in dovecot__user_accounts else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "ldap")
              
              (name "args")
              (value "/etc/dovecot/dovecot-ldap-userdb.conf")))
          
          (name "passdb_passwd")
          (option "passdb")
          (state (jinja "{{ \"present\" if \"passwdfile\" in dovecot__user_accounts else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "passwd-file")
              
              (name "args")
              (value "scheme=" (jinja "{{ dovecot__passwdfile_scheme }}") " " (jinja "{{ dovecot__passwdfile_path }}") "/" (jinja "{{ dovecot__passwdfile_name }}"))))
          
          (name "userdb_passwd")
          (option "userdb")
          (state (jinja "{{ \"present\" if \"passwdfile\" in dovecot__user_accounts else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "static")
              
              (name "args")
              (value "uid=" (jinja "{{ dovecot__vmail_posix_user }}") " gid=" (jinja "{{ dovecot__vmail_posix_group }}") " home=" (jinja "{{ dovecot__vmail_home }}"))
              
              (name "default_fields")
              (value "quota_rule=*:storage=1G")
              (comment "Default fields that can be overridden by passwd-file")
              (state "comment")
              
              (name "override_fields")
              (value "home=/home/virtual/%u")
              (comment "Override fields from passwd-file")
              (state "comment")))
          
          (name "passdb_checkpassword")
          (option "passdb")
          (state (jinja "{{ \"present\" if (\"checkpassword\" in dovecot__user_accounts and
                     dovecot__checkpassword_passdb_command | d()) else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "checkpassword")
              
              (name "args")
              (value (jinja "{{ dovecot__checkpassword_passdb_command }}"))))
          
          (name "userdb_checkpassword_pre")
          (option "userdb")
          (state (jinja "{{ \"present\" if (\"checkpassword\" in dovecot__user_accounts and
                     dovecot__checkpassword_userdb_command | d()) else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "prefetch")))
          
          (name "userdb_checkpassword_main")
          (option "userdb")
          (state (jinja "{{ \"present\" if (\"checkpassword\" in dovecot__user_accounts and
                     dovecot__checkpassword_userdb_command | d()) else \"absent\" }}"))
          (options (list
              
              (name "driver")
              (value "checkpassword")
              
              (name "args")
              (value (jinja "{{ dovecot__checkpassword_userdb_command }}"))))))
      
      (section "tls")
      (title "TLS Configuration")
      (state (jinja "{{ \"present\" if dovecot__pki is defined and dovecot__pki else \"absent\" }}"))
      (options (list
          
          (name "ssl")
          (value (jinja "{{ \"required\" if dovecot__ssl_required else \"yes\" }}"))
          
          (name "ssl_prefer_server_ciphers")
          (value "yes")
          (comment "Prefer the server's order of ciphers over the client's. (dovecot >= 2.2.6)")
          
          (name "ssl_cert")
          (value "<" (jinja "{{ dovecot__pki_path ~ \"/\" ~ dovecot__pki_realm ~ \"/\" ~ dovecot__pki_crt }}"))
          
          (name "ssl_key")
          (value "<" (jinja "{{ dovecot__pki_path ~ \"/\" ~ dovecot__pki_realm ~ \"/\" ~ dovecot__pki_key }}"))
          
          (name "ssl_protocols")
          (value (jinja "{{ dovecot__ssl_min_protocol }}"))
          (state (jinja "{{ \"present\" if dovecot__version is version(\"2.3.0\", \"<\") else \"absent\" }}"))
          
          (name "ssl_dh_parameters_length")
          (value (jinja "{{ dovecot__ssl_dh_parameters_length }}"))
          (state (jinja "{{ \"present\" if dovecot__version is version(\"2.3.0\", \"<\") else \"absent\" }}"))
          (comment "Diffie-Hellman parameters length (default 1024, dovecot >= 2.2.7, optional in dovecot >= 2.3.3)")
          
          (name "ssl_min_protocol")
          (value (jinja "{{ dovecot__ssl_min_protocol }}"))
          (state (jinja "{{ \"present\" if dovecot__version is version(\"2.3.0\", \">=\") else \"absent\" }}"))
          
          (name "ssl_dh")
          (value (jinja "{{ \"\" if (dovecot__ssl_dh_file == \"\") else (\"<\" + dovecot__ssl_dh_file) }}"))
          (state (jinja "{{ \"present\" if dovecot__version is version(\"2.3.0\", \">=\") else \"absent\" }}"))
          
          (name "ssl_cipher_list")
          (value (jinja "{{ dovecot__ssl_cipher_list }}"))
          
          (name "ssl_client_ca_dir")
          (value "/etc/ssl/certs")
          (state (jinja "{{ \"present\" if \"dsync\" in dovecot__features else \"absent\" }}"))))
      
      (section "no_tls")
      (title "TLS Non-Configuration")
      (state (jinja "{{ \"absent\" if dovecot__pki is defined and dovecot__pki else \"present\" }}"))
      (options (list
          
          (name "ssl")
          (value "no")))
      
      (section "services")
      (title "Dovecot services")
      (options (list
          
          (name "service imap-login")
          (state (jinja "{{ \"present\" if (\"imap\" in dovecot__features or \"imaps\" in dovecot__features) else \"absent\" }}"))
          (options (list
              
              (name "inet_listener imap")
              (options (list
                  
                  (name "address")
                  (value "127.0.0.1, [::1]")
                  (comment "Only localhost if no PKI is configured")
                  (state (jinja "{{ \"present\" if not dovecot__pki | d(True) else \"comment\" }}"))
                  
                  (name "port")
                  (value (jinja "{{ 143 if \"imap\" in dovecot__features else 0 }}"))))
              
              (name "inet_listener imaps")
              (options (list
                  
                  (name "port")
                  (value (jinja "{{ 993 if (\"imaps\" in dovecot__features and dovecot__pki | d(True)) else 0 }}"))
                  (comment "Disabled if no PKI is configured")))))
          
          (name "service pop3-login")
          (state (jinja "{{ \"present\" if (\"pop3\" in dovecot__features or \"pop3s\" in dovecot__features) else \"absent\" }}"))
          (options (list
              
              (name "inet_listener pop3")
              (options (list
                  
                  (name "address")
                  (value "127.0.0.1, [::1]")
                  (comment "Only localhost if no PKI is configured")
                  (state (jinja "{{ \"present\" if not dovecot__pki | d(True) else \"comment\" }}"))
                  
                  (name "port")
                  (value (jinja "{{ 110 if \"pop3\" in dovecot__features else 0 }}"))))
              
              (name "inet_listener pop3s")
              (options (list
                  
                  (name "port")
                  (value (jinja "{{ 995 if (\"pop3s\" in dovecot__features and dovecot__pki | d(True)) else 0 }}"))
                  (comment "Disabled if no PKI is configured")))))
          
          (name "service lmtp")
          (state (jinja "{{ \"present\" if \"lmtp\" in dovecot__features else \"absent\" }}"))
          (options (list
              
              (name "user")
              (value (jinja "{{ dovecot__vmail_posix_user }}"))
              (state (jinja "{{ \"present\" if dovecot__vmail_enabled | d(False) else \"absent\" }}"))
              
              (name "unix_listener /var/spool/postfix/private/dovecot-lmtp")
              (options (list
                  
                  (name "mode")
                  (value "0660")
                  
                  (name "group")
                  (value "postfix")
                  
                  (name "user")
                  (value "postfix")))))
          
          (name "service managesieve-login")
          (state (jinja "{{ \"present\" if \"sieve\" in dovecot__features else \"absent\" }}"))
          (options (list
              
              (name "inet_listener sieve")
              (options (list
                  
                  (name "port")
                  (value "4190")))))
          
          (name "service replicator")
          (state (jinja "{{ \"present\" if \"dsync\" in dovecot__features else \"absent\" }}"))
          (options (list
              
              (name "process_min_avail")
              (value "1")
              
              (name "unix_listener replicator-doveadm")
              (options (list
                  
                  (name "mode")
                  (value "0600")
                  
                  (name "user")
                  (value "vmail")))))
          
          (name "service aggregator")
          (state (jinja "{{ \"present\" if \"dsync\" in dovecot__features else \"absent\" }}"))
          (options (list
              
              (name "fifo_listener replication-notify-fifo")
              (options (list
                  
                  (name "user")
                  (value "vmail")))
              
              (name "unix_listener replication-notify")
              (options (list
                  
                  (name "user")
                  (value "vmail")))))
          
          (name "service doveadm")
          (state (jinja "{{ \"present\" if \"dsync\" in dovecot__features else \"absent\" }}"))
          (options (list
              
              (name "inet_listener doveadm")
              (options (list
                  
                  (name "port")
                  (value (jinja "{{ dovecot__dsync_port }}"))
                  
                  (name "ssl")
                  (value "yes")
                  (state (jinja "{{ \"present\" if (dovecot__pki | d(True)) else \"absent\" }}"))))))
          
          (name "replication_max_conns")
          (value "10")
          (state (jinja "{{ \"present\" if \"dsync\" in dovecot__features else \"absent\" }}"))
          
          (name "doveadm_port")
          (value (jinja "{{ dovecot__dsync_port }}"))
          (state (jinja "{{ \"present\" if \"dsync\" in dovecot__features else \"absent\" }}"))
          
          (name "doveadm_password")
          (value (jinja "{{ dovecot__dsync_password }}"))
          (state (jinja "{{ \"present\" if \"dsync\" in dovecot__features else \"absent\" }}"))
          
          (name "service auth")
          (options (list
              
              (name "unix_listener /var/spool/postfix/private/auth")
              (options (list
                  
                  (name "mode")
                  (value "0660")
                  
                  (name "group")
                  (value "postfix")
                  
                  (name "user")
                  (value "postfix")))
              
              (name "unix_listener auth-userdb")
              (state (jinja "{{ \"present\" if (dovecot__vmail_enabled | d(False) and
                         \"lmtp\" in dovecot__features) else \"absent\" }}"))
              (options (list
                  
                  (name "mode")
                  (value "0660")
                  
                  (name "group")
                  (value (jinja "{{ dovecot__vmail_posix_group }}"))
                  
                  (name "user")
                  (value (jinja "{{ dovecot__vmail_posix_user }}"))))))))
      
      (section "protocols")
      (title "Protocol settings")
      (options (list
          
          (name "protocol imap")
          (state (jinja "{{ \"present\" if (\"imap\" in dovecot__features or \"imaps\" in dovecot__features) else \"absent\" }}"))
          (options (list
              
              (name "mail_plugins")
              (value (jinja "{{ dovecot__mail_plugins_imap | flatten | join(\" \") }}"))
              
              (name "mail_max_userip_connections")
              (value "20")
              (state "comment")
              
              (name "imap_idle_notify_interval")
              (value "29 mins")
              (state "comment")))
          
          (name "protocol pop3")
          (state (jinja "{{ \"present\" if (\"pop3\" in dovecot__features or \"pop3s\" in dovecot__features) else \"absent\" }}"))
          (options (list
              
              (name "mail_plugins")
              (value (jinja "{{ dovecot__mail_plugins_pop3 | flatten | join(\" \") }}"))
              
              (name "mail_max_userip_connections")
              (value "10")
              (state "comment")))
          
          (name "protocol lda")
          (state (jinja "{{ \"present\" if \"lmtp\" not in dovecot__features else \"absent\" }}"))
          (options (list
              
              (name "mail_plugins")
              (value (jinja "{{ dovecot__mail_plugins_lda | flatten | join(\" \") }}"))
              
              (name "postmaster_address")
              (value "postmaster@" (jinja "{{ ansible_domain }}"))))
          
          (name "protocol lmtp")
          (state (jinja "{{ \"present\" if \"lmtp\" in dovecot__features else \"absent\" }}"))
          (options (list
              
              (name "mail_plugins")
              (value (jinja "{{ dovecot__mail_plugins_lmtp | flatten | join(\" \") }}"))
              
              (name "postmaster_address")
              (value "postmaster@" (jinja "{{ ansible_domain }}"))))))
      
      (section "mailbox_locations")
      (title "Mailbox Locations")
      (options (list
          
          (name "mail_home")
          (value (jinja "{{ dovecot__vmail_home }}"))
          (state (jinja "{{ \"present\" if dovecot__vmail_enabled else \"absent\" }}"))
          
          (name "mail_location")
          (value (jinja "{{ dovecot__mail_location }}"))
          (state (jinja "{{ \"present\" if dovecot__mail_location | d() else \"comment\" }}"))))
      
      (section "mailbox_namespaces")
      (title "Mailbox Namespaces")
      (options (list
          
          (name "namespace inbox")
          (options (list
              
              (name "inbox")
              (value "yes")
              (comment "There can be only one INBOX, and this setting defines which namespace has it.")
              
              (name "mailbox Drafts")
              (options (list
                  
                  (name "special_use")
                  (value "\\Drafts")))
              
              (name "mailbox Junk")
              (options (list
                  
                  (name "special_use")
                  (value "\\Junk")))
              
              (name "mailbox Trash")
              (comment "If you change the name of this mailbox and use LDAP,
dovecot__ldap_trash_field also needs to be updated.
")
              (options (list
                  
                  (name "special_use")
                  (value "\\Trash")))
              
              (name "mailbox Sent")
              (comment "For \\Sent mailboxes there are two widely used names. We'll mark both of
them as \\Sent. User typically deletes one of them if duplicates are created.
")
              (options (list
                  
                  (name "special_use")
                  (value "\\Sent")))
              
              (name "mailbox \"Sent Messages\"")
              (options (list
                  
                  (name "special_use")
                  (value "\\Sent")))
              
              (name "mailbox virtual/All")
              (comment "If you have a virtual \"All Messages\" mailbox:")
              (state "comment")
              (options (list
                  
                  (name "special_use")
                  (value "\\All")
                  
                  (name "comment")
                  (value "All my messages")))
              
              (name "mailbox virtual/Flagged")
              (comment "If you have a virtual \"Flagged\" mailbox:")
              (state "comment")
              (options (list
                  
                  (name "special_use")
                  (value "\\Flagged")
                  
                  (name "comment")
                  (value "All my flagged messages")))
              
              (name "mailbox virtual/Important")
              (comment "If you have a virtual \"Important\" mailbox:")
              (state "comment")
              (options (list
                  
                  (name "special_use")
                  (value "\\Important")
                  
                  (name "comment")
                  (value "All my important messages")))))))
      
      (section "plugins")
      (title "Mail Plugins")
      (options (list
          
          (name "plugin")
          (options (list
              
              (name "sieve")
              (value (jinja "{{ dovecot__sieve_dir }}"))
              (state (jinja "{{ \"present\" if \"sieve\" in dovecot__features else \"absent\" }}"))
              
              (name "quota")
              (value "maildir:User quota")
              (state (jinja "{{ \"present\" if \"quota\" in dovecot__features else \"absent\" }}"))
              
              (name "mail_replica")
              (value (jinja "{{ dovecot__dsync_replica }}"))
              (state (jinja "{{ \"present\" if \"dsync\" in dovecot__features else \"absent\" }}"))))))))
  (dovecot__configuration (list))
  (dovecot__group_configuration (list))
  (dovecot__host_configuration (list))
  (dovecot__combined_configuration (jinja "{{ dovecot__default_configuration
                                      + dovecot__configuration
                                      + dovecot__group_configuration
                                      + dovecot__host_configuration }}"))
  (dovecot__mail_plugins (list
      "$mail_plugins"
      (jinja "{{ \"notify\" if \"dsync\" in dovecot__features else [] }}")
      (jinja "{{ \"replication\" if \"dsync\" in dovecot__features else [] }}")
      (jinja "{{ \"quota\" if \"quota\" in dovecot__features else [] }}")))
  (dovecot__mail_plugins_imap (list
      (jinja "{{ dovecot__mail_plugins }}")
      (jinja "{{ \"imap_sieve\" if \"sieve\" in dovecot__features else [] }}")
      (jinja "{{ \"imap_quota\" if \"quota\" in dovecot__features else [] }}")))
  (dovecot__mail_plugins_pop3 (list
      (jinja "{{ dovecot__mail_plugins }}")))
  (dovecot__mail_plugins_lda (list
      (jinja "{{ dovecot__mail_plugins }}")
      (jinja "{{ \"sieve\" if \"sieve\" in dovecot__features else [] }}")))
  (dovecot__mail_plugins_lmtp (list
      (jinja "{{ dovecot__mail_plugins }}")
      (jinja "{{ \"sieve\" if \"sieve\" in dovecot__features else [] }}")))
  (dovecot__sieve_dir "file:~/sieve;active=~/.dovecot.sieve")
  (dovecot__accept_any "True")
  (dovecot__allow_imap (list))
  (dovecot__allow_imaps (list))
  (dovecot__allow_pop3 (list))
  (dovecot__allow_pop3s (list))
  (dovecot__allow_doveadm (list
      (jinja "{{ dovecot__dsync_host }}")))
  (dovecot__allow_sieve (list))
  (dovecot__ldap_enabled (jinja "{{ True
                           if (ansible_local | d() and ansible_local.ldap | d() and
                              (ansible_local.ldap.enabled | d()) | bool)
                           else False }}"))
  (dovecot__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (dovecot__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (dovecot__ldap_self_rdn "uid=dovecot")
  (dovecot__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (dovecot__ldap_self_attributes 
    (uid (jinja "{{ dovecot__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ dovecot__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"Dovecot\" service to access the LDAP directory"))
  (dovecot__ldap_binddn (jinja "{{ ([dovecot__ldap_self_rdn]
                           + dovecot__ldap_device_dn) | join(\",\") }}"))
  (dovecot__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                           + dovecot__ldap_binddn | to_uuid + \".password length=32 \"
                           + \"chars=ascii_letters,digits,!@_$%^&*\"))
                          if dovecot__ldap_enabled | bool
                          else \"\" }}"))
  (dovecot__ldap_people_rdn (jinja "{{ ansible_local.ldap.people_rdn | d(\"ou=People\") }}"))
  (dovecot__ldap_people_dn (jinja "{{ [dovecot__ldap_people_rdn]
                             + dovecot__ldap_base_dn }}"))
  (dovecot__ldap_uri (jinja "{{ ansible_local.ldap.uri | d([\"\"]) }}"))
  (dovecot__ldap_start_tls (jinja "{{ ansible_local.ldap.start_tls | d(True) | bool }}"))
  (dovecot__ldap_user_filter "(& (objectClass=mailRecipient) (| (uid=%n) (mail=%u) ) (| (authorizedService=all) (authorizedService=mail:access) ) )")
  (dovecot__ldap_user_list_filter "(& (objectClass=mailRecipient) (| (authorizedService=all) (authorizedService=mail:access) ) )")
  (dovecot__ldap_user_list_filter_attribute "mail")
  (dovecot__ldap_quota_attribute "mailQuota")
  (dovecot__ldap_quota_default "10 GB")
  (dovecot__ldap_trash_field "namespace/inbox/mailbox/Trash/autoexpunge")
  (dovecot__postfix_lmtp_transport "lmtp:unix:private/dovecot-lmtp")
  (dovecot__ldap__dependent_tasks (list
      
      (name "Create Postfix account for " (jinja "{{ dovecot__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ dovecot__ldap_binddn }}"))
      (objectClass (jinja "{{ dovecot__ldap_self_object_classes }}"))
      (attributes (jinja "{{ dovecot__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\"
                if (dovecot__ldap_enabled | bool and
                    dovecot__ldap_device_dn | d())
                else \"ignore\" }}"))))
  (dovecot__postfix__dependent_maincf (list
      
      (name "lmtp_tls_security_level")
      (comment "Security level overridden via local Dovecot installation
")
      (value (jinja "{{ \"none\"
               if dovecot__postfix_lmtp_transport.startswith(\"lmtp:unix:\")
               else \"may\" }}"))
      (state (jinja "{{ \"present\" if \"lmtp\" in dovecot__features else \"ignore\" }}"))
      
      (name "lmtp_tls_note_starttls_offer")
      (value (jinja "{{ False
               if dovecot__postfix_lmtp_transport.startswith(\"lmtp:unix:\")
               else True }}"))
      (state (jinja "{{ \"present\" if \"lmtp\" in dovecot__features else \"ignore\" }}"))
      
      (name "virtual_transport")
      (value (jinja "{{ dovecot__postfix_lmtp_transport }}"))
      (state (jinja "{{ \"present\"
               if (\"lmtp\" in dovecot__features and
                   dovecot__ldap_enabled | bool)
               else \"ignore\" }}"))
      
      (name "mailbox_transport")
      (value (jinja "{{ dovecot__postfix_lmtp_transport }}"))
      (state (jinja "{{ \"present\"
               if (\"lmtp\" in dovecot__features and
                   not dovecot__ldap_enabled | bool)
               else \"ignore\" }}"))))
  (dovecot__postfix__dependent_mastercf (list))
  (dovecot__etc_services__dependent_list (list
      
      (name "doveadm")
      (port (jinja "{{ dovecot__dsync_port }}"))
      (protocols (list
          "tcp"))
      (comment "Added by debops.dovecot Ansible role.")))
  (dovecot__ferm__dependent_rules (list
      
      (name "dovecot_imap")
      (type "accept")
      (by_role "debops.dovecot")
      (dport (list
          "imap2"))
      (saddr (jinja "{{ dovecot__allow_imap }}"))
      (accept_any (jinja "{{ dovecot__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"imap\" in dovecot__features | d([]))
                    else \"absent\" }}"))
      
      (name "dovecot_imaps")
      (type "accept")
      (by_role "debops.dovecot")
      (dport (list
          "imaps"))
      (saddr (jinja "{{ dovecot__allow_imaps }}"))
      (accept_any (jinja "{{ dovecot__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"imaps\" in dovecot__features | d([])
                         and dovecot__pki | d(True))
                    else \"absent\" }}"))
      
      (name "dovecot_pop3")
      (type "accept")
      (by_role "debops.dovecot")
      (dport (list
          "pop3"))
      (saddr (jinja "{{ dovecot__allow_pop3 }}"))
      (accept_any (jinja "{{ dovecot__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"pop3\" in dovecot__features | d([]))
                    else \"absent\" }}"))
      
      (name "dovecot_pop3s")
      (type "accept")
      (by_role "debops.dovecot")
      (dport (list
          "pop3s"))
      (saddr (jinja "{{ dovecot__allow_pop3s }}"))
      (accept_any (jinja "{{ dovecot__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"pop3s\" in dovecot__features | d([])
                         and dovecot__pki | d(True))
                    else \"absent\" }}"))
      
      (name "dovecot_doveadm")
      (type "accept")
      (by_role "debops.dovecot")
      (dport (list
          "doveadm"))
      (saddr (jinja "{{ dovecot__allow_doveadm }}"))
      (accept_any (jinja "{{ dovecot__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"dsync\" in dovecot__features | d([]))
                    else \"absent\" }}"))
      
      (name "dovecot_sieve")
      (type "accept")
      (by_role "debops.dovecot")
      (dport (list
          "sieve"))
      (saddr (jinja "{{ dovecot__allow_sieve }}"))
      (accept_any (jinja "{{ dovecot__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"sieve\" in dovecot__features | d([])
                         and dovecot__pki | d(True))
                    else \"absent\" }}")))))
