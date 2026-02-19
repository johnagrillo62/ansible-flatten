(playbook "debops/ansible/roles/dovecot/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'dovecot/pre_main.yml') }}")))
    (task "Install Dovecot packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", ([\"dovecot-core\"]
                              + ([\"dovecot-imapd\"]
                                 if (\"imap\" in dovecot__features or
                                     \"imaps\" in dovecot__features)
                                 else [])
                              + ([\"dovecot-pop3d\"]
                                 if (\"pop3\" in dovecot__features or
                                     \"pop3s\" in dovecot__features)
                                 else [])
                              + ([\"dovecot-lmtpd\"]
                                 if \"lmtp\" in dovecot__features
                                 else [])
                              + ([\"dovecot-mysql\"]
                                 if \"mysql\" in dovecot__user_accounts
                                 else [])
                              + ([\"dovecot-pgsql\"]
                                 if \"pgsql\" in dovecot__user_accounts
                                 else [])
                              + ([\"dovecot-sqlite\"]
                                 if \"sqlite\" in dovecot__user_accounts
                                 else [])
                              + ([\"dovecot-ldap\"]
                                 if \"ldap\" in dovecot__user_accounts
                                 else [])
                              + ([\"dovecot-managesieved\"]
                                 if \"sieve\" in dovecot__features
                                 else []))) }}"))
        (state "present"))
      (register "dovecot__register_packages")
      (until "dovecot__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Dovecot local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/dovecot.fact.j2")
        (dest "/etc/ansible/facts.d/dovecot.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Remove old diversions"
      (debops.debops.dpkg_divert 
        (path "/etc/dovecot/conf.d/" (jinja "{{ item }}"))
        (state "absent")
        (delete "True"))
      (loop (list
          "10-auth.conf"
          "10-master.conf"
          "10-mail.conf"
          "10-ssl.conf"
          "15-lda.conf"
          "20-pop3.conf"
          "20-imap.conf"
          "20-lmtp.conf"
          "20-managesieve.conf"
          "90-sieve.conf"
          "90-sieve-extprograms.conf"
          "auth-deny.conf.ext"
          "auth-system.conf.ext"
          "auth-sql.conf.ext"
          "auth-ldap.conf.ext"
          "auth-passwdfile.conf.ext"
          "auth-checkpassword.conf.ext")))
    (task "Uninstall disabled Dovecot protocols"
      (ansible.builtin.package 
        (pkg (jinja "{{ q(\"flattened\", (([\"dovecot-imapd\"]
                              if (\"imap\" not in dovecot__features and
                                  \"imaps\" not in dovecot__features)
                              else [])
                             + ([\"dovecot-pop3d\"]
                                if (\"pop3\" not in dovecot__features and
                                    \"pop3s\" not in dovecot__features)
                                else [])
                             + ([\"dovecot-lmtpd\"]
                                if \"lmtp\" not in dovecot__features
                                else [])
                             + ([\"dovecot-mysql\"]
                                 if \"mysql\" not in dovecot__user_accounts
                                 else [])
                             + ([\"dovecot-pgsql\"]
                                if \"pgsql\" not in dovecot__user_accounts
                                else [])
                             + ([\"dovecot-sqlite\"]
                                if \"sqlite\" not in dovecot__user_accounts
                                else [])
                             + ([\"dovecot-ldap\"]
                                if (\"ldap\" not in dovecot__user_accounts)
                                else [])
                             + ([\"dovecot-managesieved\"]
                                if \"sieve\" not in dovecot__features
                                else []))) }}"))
        (state "absent"))
      (notify (list
          "Restart dovecot")))
    (task "Remove old local configuration"
      (ansible.builtin.file 
        (path "/etc/dovecot/local.conf")
        (state "absent"))
      (notify (list
          "Restart dovecot"))
      (tags (list
          "role::dovecot:conf")))
    (task "Generate Dovecot sql configuration"
      (ansible.builtin.template 
        (src (jinja "{{ lookup('debops.debops.template_src', 'etc/dovecot/dovecot-sql.conf.ext.j2') }}"))
        (dest "/etc/dovecot/dovecot-sql.conf.ext")
        (owner "root")
        (group "root")
        (mode "0600"))
      (notify (list
          "Restart dovecot"))
      (when "dovecot__user_accounts | d([]) | intersect(['mysql', 'pgsql', 'sqlite'])")
      (tags (list
          "role::dovecot:conf"
          "role::dovecot:conf:sql")))
    (task "Generate Dovecot ldap configuration"
      (ansible.builtin.template 
        (src (jinja "{{ lookup('debops.debops.template_src', 'etc/dovecot/' + item + '.j2') }}"))
        (dest "/etc/dovecot/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0600"))
      (notify (list
          "Restart dovecot"))
      (loop (list
          "dovecot-ldap-userdb.conf"
          "dovecot-ldap-passdb.conf"))
      (when "'ldap' in dovecot__user_accounts")
      (tags (list
          "role::dovecot:conf"
          "role::dovecot:conf:ldap")))
    (task "Generate Dovecot deny user list"
      (ansible.builtin.template 
        (src (jinja "{{ lookup('debops.debops.template_src', 'etc/dovecot/dovecot.deny.j2') }}"))
        (dest "/etc/dovecot/dovecot.deny")
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Create private directory to store passwdfile"
      (ansible.builtin.file 
        (path (jinja "{{ dovecot__passwdfile_path }}"))
        (state "directory")
        (owner "root")
        (group "dovecot")
        (mode "0650"))
      (when "'passwdfile' in dovecot__user_accounts"))
    (task "Make sure virtual mail user POSIX group exists"
      (ansible.builtin.group 
        (name (jinja "{{ dovecot__vmail_posix_group |
              d(dovecot__vmail_posix_user) }}"))
        (state "present")
        (system "True"))
      (when "dovecot__vmail_enabled | d(False)")
      (tags (list
          "role::dovecot:user"
          "role::dovecot:group")))
    (task "Make sure virtual mail user POSIX system account exists"
      (ansible.builtin.user 
        (name (jinja "{{ dovecot__vmail_posix_user }}"))
        (state "present")
        (comment "Postfix Virtual Mail user")
        (group (jinja "{{ dovecot__vmail_posix_group |
               d(dovecot__vmail_posix_user) }}"))
        (home (jinja "{{ dovecot__vmail_base }}"))
        (create_home "True")
        (system "True")
        (shell "/usr/sbin/nologin")
        (skeleton null))
      (when "dovecot__vmail_enabled | d(False)")
      (tags (list
          "role::dovecot:user")))
    (task "Make sure that the virtual mail user home directory exists - " (jinja "{{ dovecot__vmail_base }}")
      (ansible.builtin.file 
        (dest (jinja "{{ dovecot__vmail_base }}"))
        (state "directory")
        (owner (jinja "{{ dovecot__vmail_posix_user }}"))
        (group (jinja "{{ dovecot__vmail_posix_group }}"))
        (mode "0750"))
      (when "dovecot__vmail_enabled | d(False)")
      (tags (list
          "role::dovecot:user")))
    (task "Make sure that PKI hook directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ dovecot__pki_hook_path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "dovecot__pki | bool"))
    (task "Manage PKI dovecot hook"
      (ansible.builtin.template 
        (src "etc/pki/hooks/dovecot.j2")
        (dest (jinja "{{ dovecot__pki_hook_path + \"/\" + dovecot__pki_hook_name }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "dovecot__pki | bool"))
    (task "Ensure the PKI dovecot hook is absent"
      (ansible.builtin.file 
        (path (jinja "{{ dovecot__pki_hook_path + \"/\" + dovecot__pki_hook_name }}"))
        (state "absent"))
      (when "not (dovecot__pki | bool)"))
    (task "Divert original Dovecot main configuration file"
      (debops.debops.dpkg_divert 
        (path "/etc/dovecot/dovecot.conf"))
      (notify (list
          "Restart dovecot"))
      (tags (list
          "role::dovecot:conf")))
    (task "Generate Dovecot main configuration file"
      (ansible.builtin.template 
        (src (jinja "{{ lookup('debops.debops.template_src', 'etc/dovecot/dovecot.conf.j2') }}"))
        (dest "/etc/dovecot/dovecot.conf")
        (owner "root")
        (group "dovecot")
        (mode "0640"))
      (notify (list
          "Restart dovecot"))
      (tags (list
          "role::dovecot:conf")))
    (task "Update Ansible facts and restart dovecot, if necessary"
      (ansible.builtin.meta "flush_handlers"))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup('debops.debops.task_src', 'dovecot/post_main.yml') }}")))))
