(playbook "debops/ansible/roles/postconf/defaults/main.yml"
  (postconf__autodetect_capabilities (jinja "{{ postconf__env_capabilities }}"))
  (postconf__default_capabilities (list
      "overhead"))
  (postconf__capabilities (list))
  (postconf__group_capabilities (list))
  (postconf__host_capabilities (list))
  (postconf__combined_capabilities (jinja "{{ postconf__autodetect_capabilities
                                     + postconf__default_capabilities
                                     + postconf__capabilities
                                     + postconf__group_capabilities
                                     + postconf__host_capabilities }}"))
  (postconf__deploy_state "present")
  (postconf__fqdn (jinja "{{ ansible_fqdn }}"))
  (postconf__sasl_auth_method (jinja "{{ \"cyrus\"
                                if (ansible_local | d() and ansible_local.saslauthd | d() and
                                    (ansible_local.saslauthd.installed | d()) | bool and
                                    \"smtpd\" in ansible_local.saslauthd.instances)
                                else \"dovecot\" }}"))
  (postconf__unauth_sender_domains (list
      (jinja "{{ postconf__fqdn }}")))
  (postconf__unauth_sender_default_action "REJECT This server requires SMTP authentication")
  (postconf__default_lookup_tables (list
      
      (name "auth_header_checks.pcre")
      (by_role "debops.postconf")
      (comment "Cleanup headers in mail messages sent by authenticated clients through
submission/smtps service.

Documentation: https://askubuntu.com/questions/78163/
")
      (default_action "IGNORE")
      (options (list
          
          (/^X-Mailer:/ "IGNORE")
          
          (/^User-Agent:/ "IGNORE")))
      (state (jinja "{{ \"present\"
               if (postconf__deploy_state == \"present\" and
                   \"authcleanup\" in postconf__combined_capabilities)
               else (\"absent\"
                     if (postconf__deploy_state == \"absent\")
                     else \"ignore\") }}"))
      
      (name "mx_access.cidr")
      (by_role "debops.postconf")
      (comment "Check if sender MX server is in subnets not accessible from the public
Internet. If so, reject mail delivery from these servers, because any
replies will be non-deliverable.
")
      (options (list
          
          (0.0.0.0/8 "REJECT Domain MX in broadcast network")
          
          (10.0.0.0/8 "REJECT Domain MX in RFC 1918 private network")
          
          (127.0.0.0/8 "REJECT Domain MX in loopback network")
          
          (169.254.0.0/16 "REJECT Domain MX in link local network")
          
          (172.16.0.0/12 "REJECT Domain MX in RFC 1918 private network")
          
          (192.0.2.0/24 "REJECT Domain MX in TEST-NET-1 network")
          
          (192.168.0.0/16 "REJECT Domain MX in RFC 1918 private network")
          
          (198.51.100.0/24 "REJECT Domain MX in TEST-NET-2 network")
          
          (203.0.113.0/24 "REJECT Domain MX in TEST-NET-3 network")
          
          (224.0.0.0/4 "REJECT Domain MX in class D multicast network")
          
          (240.0.0.0/5 "REJECT Domain MX in class E reserved network")
          
          (248.0.0.0/5 "REJECT Domain MX in reserved network")
          
          (::1/128 "REJECT Domain MX is Loopback address")
          
          (::/128 "REJECT Domain MX is Unspecified address")
          
          (::/96 "REJECT Domain MX in IPv4-Compatible IPv6")
          
          (::ffff:0:0/96 "REJECT Domain MX in IPv4-Mapped IPv6")
          
          (ff00::/8 "REJECT Domain MX in Multicast network")
          
          (fe80::/10 "REJECT Domain MX in Link-local unicast network")
          
          (fec0::/10 "REJECT Domain MX in Site-local unicast network")))
      (state (jinja "{{ \"present\"
               if (postconf__deploy_state == \"present\" and
                   \"public-mx-required\" in postconf__combined_capabilities)
               else (\"absent\"
                     if (postconf__deploy_state == \"absent\")
                     else \"ignore\") }}"))
      
      (name "unauth_sender_access.in")
      (by_role "debops.postconf")
      (comment "Block any unauthenticated external mail that uses our domain names. Users
that send this mail need to enable SMTP authentication and use the
'submission' service.

Documentation: https://serverfault.com/a/51122
")
      (default_action (jinja "{{ postconf__unauth_sender_default_action }}"))
      (content (jinja "{{ postconf__unauth_sender_domains }}"))
      (state (jinja "{{ \"present\"
               if (postconf__deploy_state == \"present\" and
                   \"auth\" in postconf__combined_capabilities and
                   \"unauth-sender\" in postconf__combined_capabilities)
               else (\"absent\"
                     if (postconf__deploy_state == \"absent\")
                     else \"ignore\") }}"))
      
      (name "overhead_checks.pcre")
      (by_role "debops.postconf")
      (comment "\"A man is not dead while his name is still spoken.\"
          - Going Postal, Chapter 4 prologue

Ref: http://www.gnuterrypratchett.com/
")
      (options (list
          
          (/^X-Clacks-Overhead:/ "IGNORE")
          
          (/^To:/ "PREPEND X-Clacks-Overhead: GNU Terry Pratchett")))
      (state (jinja "{{ \"present\"
               if (postconf__deploy_state == \"present\" and
                   \"overhead\" in postconf__combined_capabilities)
               else (\"absent\"
                     if (postconf__deploy_state == \"absent\")
                     else \"ignore\") }}"))))
  (postconf__lookup_tables (list))
  (postconf__group_lookup_tables (list))
  (postconf__host_lookup_tables (list))
  (postconf__combined_lookup_tables (jinja "{{ postconf__default_lookup_tables
                                      + postconf__lookup_tables
                                      + postconf__group_lookup_tables
                                      + postconf__host_lookup_tables }}"))
  (postconf__postfix__dependent_packages (list
      (jinja "{{ \"libsasl2-modules\"
        if (\"auth\" in postconf__combined_capabilities)
        else [] }}")))
  (postconf__postfix__dependent_lookup_tables (list
      (jinja "{{ postconf__combined_lookup_tables }}")))
  (postconf__postfix__dependent_maincf (list
      
      (name "smtpd_sasl_auth_enable")
      (value "True")
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtpd_sasl_authenticated_header")
      (value "True")
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "broken_sasl_auth_clients")
      (value "True")
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtpd_sasl_security_options")
      (value (list
          "noanonymous"
          "noplaintext"))
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtpd_sasl_tls_security_options")
      (value (list
          "noanonymous"))
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtpd_sasl_type")
      (value (jinja "{{ \"cyrus\"
               if (postconf__sasl_auth_method == \"cyrus\")
               else \"dovecot\" }}"))
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtpd_sasl_path")
      (value (jinja "{{ \"smtpd\"
               if (postconf__sasl_auth_method == \"cyrus\")
               else \"private/auth\" }}"))
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtpd_sender_restrictions")
      (value (list
          
          (name "check_sender_mx_access cidr:${config_directory}/mx_access.cidr")
          (weight "50")))
      (state (jinja "{{ \"present\"
               if (\"public-mx-required\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtpd_sender_restrictions")
      (value (list
          
          (name "permit_mynetworks")
          
          (name "reject_authenticated_sender_login_mismatch")
          (copy_id_from "permit_mynetworks")
          (weight "10")
          
          (name "permit_sasl_authenticated")
          (copy_id_from "reject_authenticated_sender_login_mismatch")
          (weight "10")
          
          (name "check_sender_access hash:${config_directory}/unauth_sender_access")
          (copy_id_from "permit_sasl_authenticated")
          (weight "10")))
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities and
                   \"unauth-sender\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtpd_relay_restrictions")
      (value (list
          
          (name "reject_authenticated_sender_login_mismatch")
          (copy_id_from "permit_mynetworks")
          (weight "10")))
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities and
                   \"unauth-sender\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtp_header_checks")
      (value (list
          "pcre:${config_directory}/overhead_checks.pcre"))
      (state (jinja "{{ \"present\"
               if (\"overhead\" in postconf__combined_capabilities)
               else \"ignore\" }}"))))
  (postconf__postfix__dependent_mastercf (list
      
      (name "submission")
      (options (list
          
          (name "smtpd_helo_restrictions")
          (value "")
          (state (jinja "{{ \"present\"
                   if (\"public-mx-required\" in postconf__combined_capabilities)
                   else \"ignore\" }}"))
          
          (name "smtpd_sender_restrictions")
          (value "reject_authenticated_sender_login_mismatch")
          (state (jinja "{{ \"present\"
                   if (\"unauth-sender\" in postconf__combined_capabilities)
                   else \"ignore\" }}"))
          
          (name "cleanup_service_name")
          (value "authcleanup")
          (state (jinja "{{ \"present\"
                   if (\"authcleanup\" in postconf__combined_capabilities)
                   else \"ignore\" }}"))))
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "smtps")
      (options (list
          
          (name "smtpd_helo_restrictions")
          (value "")
          (state (jinja "{{ \"present\"
                   if (\"public-mx-required\" in postconf__combined_capabilities)
                   else \"ignore\" }}"))
          
          (name "smtpd_sender_restrictions")
          (value "reject_authenticated_sender_login_mismatch")
          (state (jinja "{{ \"present\"
                   if (\"unauth-sender\" in postconf__combined_capabilities)
                   else \"ignore\" }}"))
          
          (name "cleanup_service_name")
          (value "authcleanup")
          (state (jinja "{{ \"present\"
                   if (\"authcleanup\" in postconf__combined_capabilities)
                   else \"ignore\" }}"))))
      (state (jinja "{{ \"present\"
               if (\"auth\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      
      (name "authcleanup")
      (type "unix")
      (private "False")
      (maxproc "0")
      (command "cleanup")
      (options (list
          
          (name "syslog_name")
          (value "postfix/authcleanup")
          
          (name "header_checks")
          (value (list
              "regexp:/etc/postfix/auth_header_checks.pcre"))))
      (state (jinja "{{ \"present\"
               if (\"authcleanup\" in postconf__combined_capabilities)
               else \"ignore\" }}"))
      (copy_id_from "cleanup")
      (weight "10"))))
