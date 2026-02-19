(playbook "debops/ansible/roles/postfix/defaults/main.yml"
  (postfix__base_packages (list
      "postfix"
      "postfix-pcre"
      "bsd-mailx"
      "make"
      "ssl-cert"
      "ca-certificates"))
  (postfix__dependent_packages (list))
  (postfix__packages (list))
  (postfix__group_packages (list))
  (postfix__host_packages (list))
  (postfix__purge_packages (list
      "exim4-base"
      "exim4-config"
      "exim4-daemon-light"
      "nullmailer"))
  (postfix__version (jinja "{{ ansible_local.postfix.version | d(\"0.0.0\") }}"))
  (postfix__doc_installed (jinja "{{ ansible_local.postfix.doc_installed
                            if (ansible_local | d() and ansible_local.postfix | d() and
                                ansible_local.postfix.doc_installed is defined)
                            else False }}"))
  (postfix__fqdn (jinja "{{ ansible_fqdn }}"))
  (postfix__domain (jinja "{{ ansible_domain }}"))
  (postfix__relayhost "")
  (postfix__mailname (jinja "{{ postfix__fqdn }}"))
  (postfix__accept_any "True")
  (postfix__allow_smtp (list))
  (postfix__allow_submission (list))
  (postfix__allow_smtps (list))
  (postfix__pki (jinja "{{ ansible_local.pki.enabled | d() | bool }}"))
  (postfix__pki_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (postfix__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (postfix__pki_ca (jinja "{{ ansible_local.pki.ca | d(\"CA.crt\") }}"))
  (postfix__pki_crt (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (postfix__pki_key (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (postfix__tls_ca_file "/etc/ssl/certs/ca-certificates.crt")
  (postfix__tls_cert_file (jinja "{{ (postfix__pki_path + \"/\" + postfix__pki_realm + \"/\" + postfix__pki_crt)
                            if postfix__pki | bool else \"/etc/ssl/certs/ssl-cert-snakeoil.pem\" }}"))
  (postfix__tls_key_file (jinja "{{ (postfix__pki_path + \"/\" + postfix__pki_realm + \"/\" + postfix__pki_key)
                           if postfix__pki | bool else \"/etc/ssl/private/ssl-cert-snakeoil.key\" }}"))
  (postfix__pki_hook_name "postfix")
  (postfix__pki_hook_path (jinja "{{ ansible_local.pki.hooks | d(\"/etc/pki/hooks\") }}"))
  (postfix__pki_hook_action "reload")
  (postfix__dhparam (jinja "{{ ansible_local.dhparam.enabled
                      if (ansible_local | d() and ansible_local.dhparam | d() and
                          ansible_local.dhparam.enabled is defined)
                      else False }}"))
  (postfix__dhparam_set "default")
  (postfix__tls_dh1024_param_file (jinja "{{ ansible_local.dhparam[postfix__dhparam_set]
                                    if (ansible_local | d() and ansible_local.dhparam | d() and
                                        ansible_local.dhparam[postfix__dhparam_set] | d())
                                    else \"\" }}"))
  (postfix__tls_dh512_param_file (jinja "{{ ansible_local.dhparam[postfix__dhparam_set]
                                   if (ansible_local | d() and ansible_local.dhparam | d() and
                                       ansible_local.dhparam[postfix__dhparam_set] | d())
                                   else \"\" }}"))
  (postfix__original_maincf (list
      
      (name "myorigin_example")
      (option "myorigin")
      (value "/etc/mailname")
      (comment "Debian specific:  Specifying a file name will cause the first
line of that file to be used as the name.  The Debian default
is /etc/mailname.
")
      (state "comment")
      (section "base")
      
      (name "smtpd_banner")
      (value "$myhostname ESMTP $mail_name (Debian/GNU)")
      (section "base")
      
      (name "biff")
      (value "False")
      (section "base")
      
      (name "append_dot_mydomain")
      (value "False")
      (comment "appending .domain is the MUA's job.")
      (section "base")
      
      (name "delay_warning_time")
      (value "4h")
      (comment "Uncomment the next line to generate \"delayed mail\" warnings")
      (state "comment")
      (section "base")
      
      (name "readme_directory")
      (value (jinja "{{ \"/usr/share/doc/postfix\"
               if postfix__doc_installed | bool
               else False }}"))
      (section "base")
      
      (name "compatibility_level")
      (value "2")
      (comment "See http://www.postfix.org/COMPATIBILITY_README.html -- default to 2 on
fresh installs.
")
      (section "base")
      (state (jinja "{{ \"present\"
               if (postfix__version is version_compare(\"3.0.0\", \">=\"))
               else \"ignore\" }}"))
      
      (name "smtpd_tls_cert_file")
      (value (jinja "{{ postfix__tls_cert_file }}"))
      (comment "TLS parameters")
      (section "base")
      
      (name "smtpd_tls_key_file")
      (value (jinja "{{ postfix__tls_key_file }}"))
      (section "base")
      
      (name "smtpd_use_tls")
      (value "True")
      (section "base")
      
      (name "smtpd_tls_session_cache_database")
      (value "btree:${data_directory}/smtpd_scache")
      (section "base")
      
      (name "smtp_tls_session_cache_database")
      (value "btree:${data_directory}/smtp_scache")
      (section "base")
      
      (name "smtp_tls_client_comment")
      (comment "See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
information on enabling SSL in the smtp client.
")
      (state "hidden")
      (section "base")
      
      (name "smtpd_relay_restrictions")
      (section "base")
      (state (jinja "{{ \"present\"
               if (postfix__version is version_compare(\"2.10.0\", \">=\"))
               else \"ignore\" }}"))
      (value (list
          
          (name "permit_mynetworks")
          (weight "-300")
          
          (name "permit_sasl_authenticated")
          (weight "-200")
          
          (name "defer_unauth_destination")
          (weight "-100")))
      
      (name "myhostname")
      (value (jinja "{{ postfix__fqdn }}"))
      (section "base")
      
      (name "alias_maps")
      (value (list
          "hash:/etc/aliases"))
      (section "base")
      
      (name "alias_database")
      (value (list
          "hash:/etc/aliases"))
      (section "base")
      
      (name "myorigin")
      (value "/etc/mailname")
      (section "base")
      
      (name "mydestination")
      (section "base")
      (value (list
          (jinja "{{ postfix__fqdn }}")
          
          (name "localhost." (jinja "{{ postfix__domain }}"))
          (weight "190")
          
          (name "localhost")
          (weight "200")))
      
      (name "relayhost")
      (value (jinja "{{ postfix__relayhost }}"))
      (section "base")
      
      (name "mynetworks")
      (section "base")
      (value (list
          
          (name "127.0.0.0/8")
          (weight "100")
          
          (name "::ffff:127.0.0.0/104")
          (weight "100")
          
          (name "::1/128")
          (weight "100")))
      
      (name "mailbox_size_limit")
      (value "0")
      (section "base")
      
      (name "recipient_delimiter")
      (value "+")
      (section "base")
      
      (name "inet_interfaces")
      (value "all")
      (section "base")
      
      (name "inet_protocols")
      (value "all")
      (section "base")
      (state (jinja "{{ \"present\"
               if (ansible_distribution_release == \"stretch\")
               else \"ignore\" }}"))
      
      (name "html_directory")
      (value (jinja "{{ \"/usr/share/doc/postfix/html\"
               if postfix__doc_installed | bool
               else False }}"))
      (section "base")))
  (postfix__default_maincf (list
      
      (name "smtpd_banner")
      (value "$myhostname ESMTP")
      
      (name "enable_long_queue_ids")
      (value "True")
      (section "base")
      (state (jinja "{{ \"present\"
               if (postfix__version is version_compare(\"2.9.0\", \">=\"))
               else \"ignore\" }}"))))
  (postfix__tls_maincf (list
      
      (name "smtp_tls_client_comment")
      (state "absent")
      
      (name "smtpd_use_tls")
      (section "smtpd-tls")
      (weight "-500")
      
      (name "smtpd_tls_cert_file")
      (section "smtpd-tls")
      (comment "")
      
      (name "smtpd_tls_key_file")
      (section "smtpd-tls")
      
      (name "smtpd_tls_CAfile")
      (value (jinja "{{ postfix__tls_ca_file }}"))
      (section "smtpd-tls")
      
      (name "smtp_tls_CAfile")
      (value (jinja "{{ postfix__tls_ca_file }}"))
      (section "smtp-tls")
      
      (name "lmtp_tls_CAfile")
      (value (jinja "{{ postfix__tls_ca_file }}"))
      (section "lmtp-tls")
      
      (name "smtpd_tls_session_cache_database")
      (section "smtpd-tls")
      
      (name "smtp_tls_session_cache_database")
      (section "smtp-tls")
      
      (name "lmtp_tls_session_cache_database")
      (value "btree:${data_directory}/lmtp_scache")
      (section "lmtp-tls")
      
      (name "smtpd_tls_dh1024_param_file")
      (value (jinja "{{ postfix__tls_dh1024_param_file }}"))
      (state (jinja "{{ \"present\" if postfix__dhparam | bool else \"ignore\" }}"))
      (section "smtpd-tls")
      
      (name "smtpd_tls_dh512_param_file")
      (value (jinja "{{ postfix__tls_dh512_param_file }}"))
      (state (jinja "{{ \"present\" if postfix__dhparam | bool else \"ignore\" }}"))
      (section "smtpd-tls")
      
      (name "smtpd_tls_loglevel")
      (value "1")
      (section "smtpd-tls")
      
      (name "smtp_tls_loglevel")
      (value "1")
      (section "smtp-tls")
      
      (name "lmtp_tls_loglevel")
      (value "1")
      (section "lmtp-tls")
      
      (name "smtpd_tls_security_level")
      (value "may")
      (section "smtpd-tls")
      (weight "-500")
      
      (name "smtp_tls_security_level")
      (value "may")
      (section "smtp-tls")
      (weight "-500")
      
      (name "lmtp_tls_security_level")
      (value "may")
      (section "lmtp-tls")
      (weight "-500")
      
      (name "smtpd_tls_auth_only")
      (value "True")
      (section "smtpd-tls")
      
      (name "smtpd_tls_protocols")
      (value (list
          "!SSLv2"
          "!SSLv3"
          "!TLSv1"
          "TLSv1.1"
          "TLSv1.2"))
      (section "smtpd-tls")
      
      (name "smtp_tls_protocols")
      (value (list
          "!SSLv2"
          "!SSLv3"
          "!TLSv1"
          "TLSv1.1"
          "TLSv1.2"))
      (section "smtp-tls")
      
      (name "lmtp_tls_protocols")
      (value (list
          "!SSLv2"
          "!SSLv3"
          "!TLSv1"
          "TLSv1.1"
          "TLSv1.2"))
      (section "lmtp-tls")
      
      (name "smtpd_tls_mandatory_protocols")
      (value (list
          "!SSLv2"
          "!SSLv3"
          "!TLSv1"
          "TLSv1.1"
          "TLSv1.2"))
      (section "smtpd-tls")
      
      (name "smtp_tls_mandatory_protocols")
      (value (list
          "!SSLv2"
          "!SSLv3"
          "!TLSv1"
          "TLSv1.1"
          "TLSv1.2"))
      (section "smtp-tls")
      
      (name "lmtp_tls_mandatory_protocols")
      (value (list
          "!SSLv2"
          "!SSLv3"
          "!TLSv1"
          "TLSv1.1"
          "TLSv1.2"))
      (section "lmtp-tls")
      
      (name "smtpd_tls_ciphers")
      (value "high")
      (section "smtpd-tls")
      
      (name "smtp_tls_ciphers")
      (value "high")
      (section "smtp-tls")
      
      (name "lmtp_tls_ciphers")
      (value "high")
      (section "lmtp-tls")
      
      (name "smtpd_tls_mandatory_ciphers")
      (value "high")
      (section "smtpd-tls")
      
      (name "smtp_tls_mandatory_ciphers")
      (value "high")
      (section "smtp-tls")
      
      (name "lmtp_tls_mandatory_ciphers")
      (value "high")
      (section "lmtp-tls")
      
      (name "smtpd_tls_exclude_ciphers")
      (value (list
          "aNULL"
          "RC4"
          "MD5"
          "DES"
          "3DES"
          "RSA"
          "SHA"))
      (section "smtpd-tls")
      
      (name "smtp_tls_exclude_ciphers")
      (value (list
          "aNULL"
          "RC4"
          "MD5"
          "DES"
          "3DES"
          "RSA"
          "SHA"))
      (section "smtp-tls")
      
      (name "lmtp_tls_exclude_ciphers")
      (value (list
          "aNULL"
          "RC4"
          "MD5"
          "DES"
          "3DES"
          "RSA"
          "SHA"))
      (section "lmtp-tls")
      
      (name "smtpd_tls_eecdh_grade")
      (value "ultra")
      (section "smtpd-tls")
      
      (name "smtpd_tls_received_header")
      (value "True")
      (section "smtpd-tls")
      
      (name "smtp_tls_note_starttls_offer")
      (value "True")
      (section "smtp-tls")
      
      (name "lmtp_tls_note_starttls_offer")
      (value "True")
      (section "lmtp-tls")
      
      (name "tls_preempt_cipherlist")
      (value "True")
      (section "tls")
      
      (name "tls_ssl_options")
      (value "NO_COMPRESSION")
      (section "tls")
      (state (jinja "{{ \"present\"
              if (postfix__version is version_compare(\"2.11.0\", \">=\"))
              else \"ignore\" }}"))))
  (postfix__restrictions_maincf (list
      
      (name "smtpd_helo_required")
      (value "True")
      (section "restrictions")
      
      (name "strict_rfc821_envelopes")
      (value "True")
      (section "restrictions")
      
      (name "smtpd_reject_unlisted_sender")
      (value "True")
      (section "restrictions")
      
      (name "disable_vrfy_command")
      (value "True")
      (section "restrictions")
      
      (name "smtpd_client_restrictions")
      (section "restrictions")
      (weight "10")
      (separator "True")
      
      (name "smtpd_helo_restrictions")
      (section "restrictions")
      (weight "20")
      (value (list
          
          (name "permit_mynetworks")
          (weight "-400")
          
          (name "reject_invalid_helo_hostname")
          (weight "-300")
          
          (name "reject_non_fqdn_helo_hostname")
          (weight "-200")
          
          (name "reject_unknown_helo_hostname")
          (weight "-100")))
      
      (name "smtpd_sender_restrictions")
      (section "restrictions")
      (weight "30")
      (value (list
          
          (name "reject_non_fqdn_sender")
          (weight "-200")
          
          (name "reject_unknown_sender_domain")
          (weight "-100")
          
          (name "permit_mynetworks")))
      
      (name "smtpd_relay_restrictions")
      (section "restrictions")
      (copy_id_from "smtpd_sender_restrictions")
      (weight "40")
      (state (jinja "{{ \"present\"
               if (postfix__version is version_compare(\"2.10.0\", \">=\"))
               else \"ignore\" }}"))
      
      (name "smtpd_recipient_restrictions")
      (section "restrictions")
      (weight "50")
      (value (list
          
          (name "reject_non_fqdn_recipient")
          (weight "-200")
          
          (name "reject_unknown_recipient_domain")
          (weight "-100")))
      
      (name "smtpd_data_restrictions")
      (section "restrictions")
      (weight "60")
      (value (list
          
          (name "reject_unauth_pipelining")
          (weight "-200")
          
          (name "reject_multi_recipient_bounce")
          (weight "-100")))
      
      (name "smtpd_discard_ehlo_keywords")
      (section "restrictions")
      (value (list
          "dsn"
          "etrn"))))
  (postfix__maincf (list))
  (postfix__group_maincf (list))
  (postfix__host_maincf (list))
  (postfix__dependent_maincf (list))
  (postfix__combined_maincf (jinja "{{ postfix__original_maincf
                              + postfix__default_maincf
                              + postfix__tls_maincf
                              + postfix__restrictions_maincf
                              + postfix__env_persistent_maincf
                              + postfix__maincf
                              + postfix__group_maincf
                              + postfix__host_maincf }}"))
  (postfix__init_maincf (jinja "{{ lookup(\"template\",
                          \"lookup/postfix__init_maincf.j2\") }}"))
  (postfix__maincf_sections (list
      
      (name "base")
      
      (name "auth")
      (title "Authentication and authorization")
      
      (name "route")
      (title "Message routing")
      
      (name "virtual")
      (title "Virtual mail configuration")
      
      (name "tls")
      (title "TLS/SSL configuration")
      
      (name "smtpd-tls")
      (title "SMTP Server (smtpd) TLS configuration")
      
      (name "smtp-tls")
      (title "SMTP Client (smtp) TLS configuration")
      
      (name "lmtp-tls")
      (title "Local Mail Transfer Protocol (lmtp) TLS configuration")
      
      (name "postscreen")
      (title "postscreen options")
      
      (name "restrictions")
      (title "SMTP Server (smtpd) restrictions")
      
      (name "filter")
      (title "Mail filtering configuration")
      
      (name "limit")
      (title "Rate limits")
      
      (name "unknown")
      (title "Other options")))
  (postfix__original_mastercf (list
      
      (name "smtp")
      (type "inet")
      (private "False")
      (chroot "True")
      (command "smtpd")
      
      (name "postscreen")
      (service "smtp")
      (type "inet")
      (private "False")
      (chroot "True")
      (maxproc "1")
      (command "postscreen")
      (state "comment")
      
      (name "smtpd")
      (type "pass")
      (chroot "True")
      (state "comment")
      
      (name "dnsblog")
      (type "unix")
      (chroot "True")
      (maxproc "0")
      (state "comment")
      
      (name "tlsproxy")
      (type "unix")
      (chroot "True")
      (maxproc "0")
      (state "comment")
      
      (name "submission")
      (type "inet")
      (private "False")
      (chroot "True")
      (command "smtpd")
      (state "comment")
      (options (list
          
          (syslog_name "postfix/submission")
          
          (smtpd_tls_security_level "encrypt")
          
          (smtpd_sasl_auth_enable "True")
          
          (smtpd_reject_unlisted_recipient "False")
          
          (name "smtpd_client_restrictions")
          (value "$mua_client_restrictions")
          (state "comment")
          
          (name "smtpd_helo_restrictions")
          (value "$mua_helo_restrictions")
          (state "comment")
          
          (name "smtpd_sender_restrictions")
          (value "$mua_sender_restrictions")
          (state "comment")
          
          (smtpd_recipient_restrictions "")
          
          (name "smtpd_relay_restrictions")
          (value (list
              "permit_sasl_authenticated"
              "reject"))
          (state (jinja "{{ \"present\"
                  if (postfix__version is version_compare(\"2.10.0\", \">=\"))
                  else \"ignore\" }}"))
          
          (milter_macro_daemon_name "ORIGINATING")))
      
      (name "smtps")
      (type "inet")
      (private "False")
      (chroot "True")
      (command "smtpd")
      (state "comment")
      (options (list
          
          (syslog_name "postfix/smtps")
          
          (smtpd_tls_wrappermode "True")
          
          (smtpd_sasl_auth_enable "True")
          
          (smtpd_reject_unlisted_recipient "False")
          
          (name "smtpd_client_restrictions")
          (value "$mua_client_restrictions")
          (state "comment")
          
          (name "smtpd_helo_restrictions")
          (value "$mua_helo_restrictions")
          (state "comment")
          
          (name "smtpd_sender_restrictions")
          (value "$mua_sender_restrictions")
          (state "comment")
          
          (smtpd_recipient_restrictions "")
          
          (name "smtpd_relay_restrictions")
          (value (list
              "permit_sasl_authenticated"
              "reject"))
          (state (jinja "{{ \"present\"
                  if (postfix__version is version_compare(\"2.10.0\", \">=\"))
                  else \"ignore\" }}"))
          
          (milter_macro_daemon_name "ORIGINATING")))
      
      (name "qmqp")
      (service "628")
      (type "inet")
      (private "False")
      (chroot "True")
      (command "qmqpd")
      (state "comment")
      
      (name "pickup")
      (type "unix")
      (private "False")
      (chroot "True")
      (wakeup "60")
      (maxproc "1")
      
      (name "cleanup")
      (type "unix")
      (private "False")
      (chroot "True")
      (maxproc "0")
      
      (name "qmgr")
      (type "unix")
      (private "False")
      (chroot "False")
      (wakeup "300")
      (maxproc "1")
      
      (name "oqmgr")
      (service "qmgr")
      (type "unix")
      (private "False")
      (chroot "False")
      (wakeup "300")
      (maxproc "1")
      (command "oqmgr")
      (state "comment")
      
      (name "tlsmgr")
      (type "unix")
      (chroot "True")
      (wakeup "1000?")
      (maxproc "1")
      
      (name "rewrite")
      (type "unix")
      (chroot "True")
      (command "trivial-rewrite")
      
      (name "bounce")
      (type "unix")
      (chroot "True")
      (maxproc "0")
      
      (name "defer")
      (type "unix")
      (chroot "True")
      (maxproc "0")
      (command "bounce")
      
      (name "trace")
      (type "unix")
      (chroot "True")
      (maxproc "0")
      (command "bounce")
      
      (name "verify")
      (type "unix")
      (chroot "True")
      (maxproc "1")
      
      (name "flush")
      (type "unix")
      (private "False")
      (chroot "True")
      (wakeup "1000?")
      (maxproc "0")
      
      (name "proxymap")
      (type "unix")
      (chroot "False")
      
      (name "proxywrite")
      (type "unix")
      (chroot "False")
      (maxproc "1")
      (command "proxymap")
      
      (name "smtp_unix")
      (service "smtp")
      (type "unix")
      (chroot "True")
      (command "smtp")
      
      (name "relay")
      (type "unix")
      (chroot "True")
      (command "smtp")
      (options (list
          
          (name "smtp_helo_timeout")
          (value "5")
          (state "comment")
          
          (name "smtp_connect_timeout")
          (value "5")
          (state "comment")))
      
      (name "showq")
      (type "unix")
      (chroot "True")
      (private "False")
      
      (name "error")
      (type "unix")
      (chroot "True")
      
      (name "retry")
      (type "unix")
      (chroot "True")
      (command "error")
      
      (name "discard")
      (type "unix")
      (chroot "True")
      
      (name "local")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      
      (name "virtual")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      
      (name "lmtp")
      (type "unix")
      (chroot "True")
      
      (name "anvil")
      (type "unix")
      (chroot "True")
      (maxproc "1")
      
      (name "scache")
      (type "unix")
      (chroot "True")
      (maxproc "1")
      
      (name "non-postfix-sftware")
      (comment "====================================================================
Interfaces to non-Postfix software. Be sure to examine the manual
pages of the non-Postfix software to find out what options it wants.

Many of the following services use the Postfix pipe(8) delivery
agent.  See the pipe(8) man page for information about ${recipient}
and other message envelope options.
====================================================================
")
      (state "hidden")
      
      (name "maildrop")
      (comment "maildrop. See the Postfix MAILDROP_README file for details.
Also specify in main.cf: maildrop_destination_recipient_limit=1
")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (command "pipe")
      (args "flags=DRhu user=vmail argv=/usr/bin/maildrop -d ${recipient}")
      
      (name "cyrus-lmtp-note")
      (comment "====================================================================

Recent Cyrus versions can use the existing \"lmtp\" master.cf entry.

Specify in cyrus.conf:
  lmtp    cmd=\"lmtpd -a\" listen=\"localhost:lmtp\" proto=tcp4

Specify in main.cf one or more of the following:
 mailbox_transport = lmtp:inet:localhost
 virtual_transport = lmtp:inet:localhost

====================================================================
")
      (state "hidden")
      
      (name "cyrus")
      (comment "Cyrus 2.1.5 (Amos Gouaux)
Also specify in main.cf: cyrus_destination_recipient_limit=1
")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (command "pipe")
      (args "user=cyrus argv=/cyrus/bin/deliver -e -r ${sender} -m ${extension} ${user}")
      (state "comment")
      
      (name "old-cyrus")
      (comment "====================================================================
Old example of delivery via Cyrus.
")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (command "pipe")
      (args "flags=R user=cyrus argv=/cyrus/bin/deliver -e -m ${extension} ${user}")
      (state "comment")
      
      (name "uucp")
      (comment "====================================================================

See the Postfix UUCP_README file for configuration details.
")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (command "pipe")
      (args "flags=Fqhu user=uucp argv=uux -r -n -z -a$sender - $nexthop!rmail ($recipient)")
      
      (name "other-delivery-methods")
      (comment "Other external delivery methods.")
      (state "hidden")
      
      (name "ifmail")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (command "pipe")
      (args "flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r $nexthop ($recipient)")
      
      (name "bsmtp")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (command "pipe")
      (args "flags=Fq. user=bsmtp argv=/usr/lib/bsmtp/bsmtp -t$nexthop -f$sender $recipient")
      
      (name "scalemail-backend")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (maxproc "2")
      (command "pipe")
      (args "flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store ${nexthop} ${user} ${extension}")
      
      (name "mailman")
      (type "unix")
      (unpriv "False")
      (chroot "False")
      (args "flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py
${nexthop} ${user}
")
      (command "pipe")))
  (postfix__default_mastercf (list))
  (postfix__tls_mastercf (list
      
      (name "submission")
      (options (list
          
          (tls_preempt_cipherlist "True")))
      
      (name "smtps")
      (options (list
          
          (tls_preempt_cipherlist "True")))))
  (postfix__mastercf (list))
  (postfix__group_mastercf (list))
  (postfix__host_mastercf (list))
  (postfix__dependent_mastercf (list))
  (postfix__combined_mastercf (jinja "{{ postfix__original_mastercf
                                + postfix__default_mastercf
                                + postfix__tls_mastercf
                                + postfix__env_persistent_mastercf
                                + postfix__mastercf
                                + postfix__group_mastercf
                                + postfix__host_mastercf }}"))
  (postfix__lookup_tables (list))
  (postfix__group_lookup_tables (list))
  (postfix__host_lookup_tables (list))
  (postfix__dependent_lookup_tables (list))
  (postfix__dependent_lookup_tables_filter (jinja "{{ lookup(\"flattened\",
                                             postfix__dependent_lookup_tables) }}"))
  (postfix__combined_lookup_tables (jinja "{{ ([postfix__dependent_lookup_tables_filter]
                                      if postfix__dependent_lookup_tables_filter is mapping
                                      else postfix__dependent_lookup_tables_filter)
                                     + postfix__lookup_tables
                                     + postfix__group_lookup_tables
                                     + postfix__host_lookup_tables }}"))
  (postfix__ferm__dependent_rules (list
      
      (name "postfix_smtp")
      (type "accept")
      (by_role "debops.postfix")
      (dport (list
          "smtp"))
      (saddr (jinja "{{ postfix__allow_smtp }}"))
      (accept_any (jinja "{{ postfix__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"smtp\" in postfix__env_active_services | d([]))
                    else \"absent\" }}"))
      
      (name "postfix_smtps")
      (type "accept")
      (by_role "debops.postfix")
      (dport (list
          "smtps"))
      (saddr (jinja "{{ postfix__allow_smtps }}"))
      (accept_any (jinja "{{ postfix__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"smtps\" in postfix__env_active_services | d([]))
                    else \"absent\" }}"))
      
      (name "postfix_submission")
      (type "accept")
      (by_role "debops.postfix")
      (dport (list
          "submission"))
      (saddr (jinja "{{ postfix__allow_submission }}"))
      (accept_any (jinja "{{ postfix__accept_any }}"))
      (rule_state (jinja "{{ \"present\"
                    if (\"submission\" in postfix__env_active_services | d([]))
                    else \"absent\" }}")))))
