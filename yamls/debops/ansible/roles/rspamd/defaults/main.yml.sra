(playbook "debops/ansible/roles/rspamd/defaults/main.yml"
  (rspamd__packages (list))
  (rspamd__base_packages (list
      "rspamd"
      (jinja "{{ \"bind9-dnsutils\" if rspamd__dkim_update_method is search(\"nsupdate\") else [] }}")
      (jinja "{{ \"krb5-user\" if rspamd__dkim_update_method == \"nsupdate_gsstsig\" else [] }}")))
  (rspamd__dkim_enabled "False")
  (rspamd__dkim_domains (list
      (jinja "{{ ansible_domain }}")))
  (rspamd__dkim_log_dir "/var/log/rspamd")
  (rspamd__dkim_keygen_default_configuration (list
      
      (name "key_directory")
      (value "/var/lib/rspamd/dkim/")
      
      (name "key_archive")
      (value "/var/lib/rspamd/dkim-archive/")
      
      (name "update_script")
      (value "/usr/local/sbin/rspamd-dkim-update")
      
      (name "future_config")
      (value "dkim-future.conf")
      
      (name "active_config")
      (value "dkim-active.conf")
      
      (name "expired_config")
      (value "dkim-expired.conf")
      
      (name "future_period")
      (value "1")
      
      (name "active_period")
      (value "3")
      
      (name "expired_period")
      (value "1")
      
      (name "domains")
      (value (jinja "{{ rspamd__dkim_domains }}"))
      
      (name "key_types")
      (value (list
          
          (type "ed25519")
          
          (type "rsa")
          (extra_args (list
              "--bits"
              "2048"))))))
  (rspamd__dkim_keygen_configuration (list))
  (rspamd__dkim_keygen_group_configuration (list))
  (rspamd__dkim_keygen_host_configuration (list))
  (rspamd__dkim_keygen_combined_configuration (jinja "{{
  rspamd__dkim_keygen_default_configuration
   + rspamd__dkim_keygen_configuration
   + rspamd__dkim_keygen_group_configuration
   + rspamd__dkim_keygen_host_configuration }}"))
  (rspamd__dkim_update_method "email")
  (rspamd__dkim_update_default_configuration (list
      
      (name "method")
      (value (jinja "{{ rspamd__dkim_update_method }}"))
      
      (name "log_file")
      (value (jinja "{{ rspamd__dkim_log_dir + \"/rspamd-dkim-update.log\" }}"))
      
      (name "email_to")
      (value (jinja "{{ ansible_local.core.admin_public_email[0]
               | d(\"root@\" + ansible_domain) }}"))
      
      (name "email_from")
      (value (jinja "{{ \"noreply@\" + ansible_domain }}"))
      
      (name "email_host")
      (value "localhost")
      
      (name "email_port")
      (value "25")
      
      (name "email_subject")
      (value "Rspamd DKIM DNS updates")
      
      (name "nsupdate_keyfile")
      (value (jinja "{{ \"\" if rspamd__dkim_update_method in [\"email\", \"nsupdate\"]
               else \"/etc/rspamd/dkim_dns_key\" }}"))
      
      (name "nsupdate_gsstsig_princ")
      (value (jinja "{{ \"\" if rspamd__dkim_update_method != \"nsupdate_gsstsig\"
               else \"rspamd@\" + ansible_domain | upper }}"))
      
      (name "nsupdate_ttl")
      (value "3600")
      
      (name "nsupdate_server")
      (value (jinja "{{ ansible_dns.nameservers[0] | d(\"\") }}"))))
  (rspamd__dkim_update_configuration (list))
  (rspamd__dkim_update_group_configuration (list))
  (rspamd__dkim_update_host_configuration (list))
  (rspamd__dkim_update_combined_configuration (jinja "{{
  rspamd__dkim_update_default_configuration
   + rspamd__dkim_update_configuration
   + rspamd__dkim_update_group_configuration
   + rspamd__dkim_update_host_configuration }}"))
  (rspamd__redis_host (jinja "{{ ansible_local.redis_server.host | d(\"127.0.0.1\") }}"))
  (rspamd__redis_port (jinja "{{ ansible_local.redis_server.port | d(\"6379\") }}"))
  (rspamd__redis_password (jinja "{{ ansible_local.redis_server.password | d(\"\") }}"))
  (rspamd__redis_db "0")
  (rspamd__default_local_configuration (list
      
      (file "worker-proxy.inc")
      (comment "Proxy worker configuration
https://rspamd.com/doc/workers/rspamd_proxy.html
")
      (options (list
          
          (name "bind_socket")
          (value "localhost:11332")
          
          (name "milter")
          (value "True")
          
          (name "timeout")
          (value "120")
          
          (name "upstream \"local\"")
          (options (list
              
              (name "default")
              (value "True")
              
              (name "self_scan")
              (value "True")))))
      
      (file "worker-controller.inc")
      (comment "Controller worker configuration
https://rspamd.com/doc/workers/controller.html
")
      (options (list
          
          (name "password")
          (value (jinja "{{ rspamd__controller_password_hash }}"))))
      
      (file "redis.conf")
      (comment "Redis configuration
https://rspamd.com/doc/configuration/redis.html
")
      (options (list
          
          (name "servers")
          (value (jinja "{{ rspamd__redis_host }}") ":" (jinja "{{ rspamd__redis_port }}"))
          
          (name "db")
          (value (jinja "{{ rspamd__redis_db }}"))
          
          (name "password")
          (value (jinja "{{ rspamd__redis_password }}"))))
      
      (file "milter_headers.conf")
      (comment "Milter headers configuration
https://rspamd.com/doc/modules/milter_headers.html
")
      (options (list
          
          (name "use")
          (value (list
              "x-spamd-bar"
              "x-spam-level"
              "authentication-results"))
          
          (name "authenticated_headers")
          (value (list
              "authentication-results"))))
      
      (file "dkim_signing.conf")
      (comment "DKIM signing configuration
https://rspamd.com/doc/modules/dkim_signing.html
")
      (state (jinja "{{ \"present\" if rspamd__dkim_enabled | d(False) else \"absent\" }}"))
      (options (list
          
          (name "allow_username_mismatch")
          (value "True")
          
          (name "include_dkim_keys")
          (raw ".include(try=true,priority=1,duplicate=merge) \"/var/lib/rspamd/dkim/dkim-active.conf\"")))
      
      (file "arc.conf")
      (comment "ARC signature check configuration
https://rspamd.com/doc/modules/arc.html
")
      (state (jinja "{{ \"present\" if rspamd__dkim_enabled | d(False) else \"absent\" }}"))
      (options (list
          
          (name "allow_username_mismatch")
          (value "True")
          
          (name "include_dkim_keys")
          (raw ".include(try=true,priority=1,duplicate=merge) \"/var/lib/rspamd/dkim/dkim-active.conf\"")))))
  (rspamd__local_configuration (list))
  (rspamd__group_local_configuration (list))
  (rspamd__host_local_configuration (list))
  (rspamd__combined_local_configuration (jinja "{{ rspamd__default_local_configuration
                                           + rspamd__local_configuration
                                           + rspamd__group_local_configuration
                                           + rspamd__host_local_configuration }}"))
  (rspamd__default_override_configuration (list))
  (rspamd__override_configuration (list))
  (rspamd__group_override_configuration (list))
  (rspamd__host_override_configuration (list))
  (rspamd__combined_override_configuration (jinja "{{ rspamd__default_override_configuration
                                              + rspamd__override_configuration
                                              + rspamd__group_override_configuration
                                              + rspamd__host_override_configuration }}"))
  (rspamd__controller_password (jinja "{{ lookup(\"password\",
                                        secret
                                         + \"/credentials/\"
                                         + inventory_hostname
                                         + \"/rspamd/controller_password\"
                                         + \" chars=ascii_letters,digits\"
                                         + \" length=32\") }}"))
  (rspamd__controller_password_salt (jinja "{{ (lookup(\"password\",
                                              secret
                                               + \"/credentials/\"
                                               + inventory_hostname
                                               + \"/rspamd/salt\"
                                               + \" chars=ascii_letters,digits\"
                                               + \" length=21\"))[:21]
                                      + (\"Oeu\"
                                          | shuffle(seed=inventory_hostname)
                                          | join)[1] }}"))
  (rspamd__controller_password_hash (jinja "{{ rspamd__controller_password
                                      | password_hash(\"bcrypt\",
                                                      salt=rspamd__controller_password_salt) }}"))
  (rspamd__nginx_enabled "False")
  (rspamd__nginx_fqdns (list
      "rspamd." (jinja "{{ ansible_domain }}")
      (jinja "{{ ansible_hostname }}") "-rspamd." (jinja "{{ ansible_domain }}")))
  (rspamd__nginx_access_policy "")
  (rspamd__proxy_allow (list))
  (rspamd__normal_allow (list))
  (rspamd__controller_allow (list))
  (rspamd__fuzzy_allow (list))
  (rspamd__logrotate__dependent_config (list
      
      (filename "rspamd-dkim")
      (logs (jinja "{{ rspamd__dkim_log_dir + \"/rspamd-dkim-update.log\" }}"))
      (options "notifempty
missingok
yearly
maxsize 16M
rotate 10
compress
")
      (comment "Rspamd DKIM key rotation logs")))
  (rspamd__etc_services__dependent_list (list
      
      (name "rspamd-proxy")
      (port "11332")
      (protocols (list
          "tcp"))
      (comment "Added by debops.rspamd Ansible role.")
      
      (name "rspamd-normal")
      (port "11333")
      (protocols (list
          "tcp"))
      (comment "Added by debops.rspamd Ansible role.")
      
      (name "rspamd-controller")
      (port "11334")
      (protocols (list
          "tcp"))
      (comment "Added by debops.rspamd Ansible role.")
      
      (name "rspamd-fuzzy")
      (port "11335")
      (protocols (list
          "udp"))
      (comment "Added by debops.rspamd Ansible role.")))
  (rspamd__nginx__dependent_servers (list
      
      (name (jinja "{{ rspamd__nginx_fqdns }}"))
      (filename "debops.rspamd")
      (by_role "debops.rspamd")
      (access_policy (jinja "{{ rspamd__nginx_access_policy }}"))
      (webroot_create "False")
      (type "proxy")
      (proxy_pass "http://localhost:11334")))
  (rspamd__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "rspamd-proxy"))
      (protocol (list
          "tcp"))
      (saddr (jinja "{{ rspamd__proxy_allow }}"))
      (accept_any "False")
      (weight "50")
      (role "rspamd")
      
      (type "accept")
      (dport (list
          "rspamd-normal"))
      (protocol (list
          "tcp"))
      (saddr (jinja "{{ rspamd__normal_allow }}"))
      (accept_any "False")
      (weight "50")
      (role "rspamd")
      
      (type "accept")
      (dport (list
          "rspamd-controller"))
      (protocol (list
          "tcp"))
      (saddr (jinja "{{ rspamd__controller_allow }}"))
      (accept_any "False")
      (weight "50")
      (role "rspamd")
      
      (type "accept")
      (dport (list
          "rspamd-fuzzy"))
      (protocol (list
          "udp"))
      (saddr (jinja "{{ rspamd__fuzzy_allow }}"))
      (accept_any "False")
      (weight "50")
      (role "rspamd")))
  (rspamd__postfix__dependent_maincf (list
      
      (name "smtpd_milters")
      (comment "Added by the rspamd role")
      (value (list
          
          (name "inet:localhost:11332")
          (weight "-400")))
      (state "present")
      
      (name "non_smtpd_milters")
      (comment "Added by the rspamd role")
      (value (list
          
          (name "inet:localhost:11332")
          (weight "-400")))
      (state "present")
      
      (name "milter_mail_macros")
      (comment "Added by the rspamd role")
      (value (jinja "{{ \"i {auth_type} {auth_authen} {auth_author} \"
               + \"{client_addr} {client_name} {mail_addr} \"
               + \"{mail_host} {mail_mailer}\" }}"))
      (state "present")
      
      (name "milter_default_action")
      (comment "Added by the rspamd role")
      (value "accept")
      (state "comment")
      
      (name "milter_protocol")
      (comment "Added by the rspamd role")
      (value "6")
      (state "comment"))))
