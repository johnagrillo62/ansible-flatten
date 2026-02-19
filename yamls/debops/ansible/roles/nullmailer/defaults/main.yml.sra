(playbook "debops/ansible/roles/nullmailer/defaults/main.yml"
  (nullmailer__enabled "True")
  (nullmailer__skip_mta "True")
  (nullmailer__skip_mta_packages (list
      "postfix"))
  (nullmailer__purge_mta_packages (list
      "exim4-base"
      "exim4-config"
      "exim4-daemon-light"
      "postfix"
      "msmtp-mta"
      "dma"))
  (nullmailer__base_packages (list
      "nullmailer"
      "bsd-mailx"))
  (nullmailer__smtpd_packages (jinja "{{ [\"xinetd\"] if nullmailer__smtpd | bool else [] }}"))
  (nullmailer__packages (list))
  (nullmailer__mailname (jinja "{{ nullmailer__fqdn }}"))
  (nullmailer__fqdn (jinja "{{ ansible_fqdn }}"))
  (nullmailer__domain (jinja "{{ ansible_domain }}"))
  (nullmailer__adminaddr (list
      (jinja "{{ \"root@\" + nullmailer__relayhost }}")))
  (nullmailer__idhost (jinja "{{ nullmailer__fqdn }}"))
  (nullmailer__helohost (jinja "{{ nullmailer__fqdn }}"))
  (nullmailer__defaulthost (jinja "{{ nullmailer__mailname }}"))
  (nullmailer__defaultdomain (jinja "{{ nullmailer__domain }}"))
  (nullmailer__allmailfrom "")
  (nullmailer__ldap_enabled (jinja "{{ ansible_local.ldap.enabled
                              if (ansible_local | d() and ansible_local.ldap | d() and
                                  ansible_local.ldap.enabled is defined)
                              else False }}"))
  (nullmailer__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (nullmailer__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (nullmailer__ldap_self_rdn "uid=nullmailer")
  (nullmailer__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"
      "authorizedServiceObject"))
  (nullmailer__ldap_self_attributes 
    (uid (jinja "{{ nullmailer__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ nullmailer__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"nullmailer\" service to send authenticated mail messages")
    (authorizedService "mail:send"))
  (nullmailer__ldap_binddn (jinja "{{ ([nullmailer__ldap_self_rdn] + nullmailer__ldap_device_dn) | join(\",\") }}"))
  (nullmailer__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                     + nullmailer__ldap_binddn | to_uuid + \".password length=32\"))
                             if nullmailer__ldap_enabled | bool
                             else \"\" }}"))
  (nullmailer__starttls "True")
  (nullmailer__smtp_srv_rr (jinja "{{ q(\"debops.debops.dig_srv\", \"_smtp._tcp.\" + nullmailer__domain,
                               \"smtp.\" + nullmailer__domain, 25)
                             if nullmailer__enabled | bool
                             else [] }}"))
  (nullmailer__smtp_port (jinja "{{ nullmailer__smtp_srv_rr[0][\"port\"] }}"))
  (nullmailer__relayhost (jinja "{{ nullmailer__smtp_srv_rr[0][\"target\"] }}"))
  (nullmailer__relayhost_options (list
      "--port=" (jinja "{{ nullmailer__smtp_port }}")
      (jinja "{{ \"--ssl\"
        if (nullmailer__smtp_port == \"465\")
        else \"--starttls\" }}")))
  (nullmailer__default_remotes (list
      
      (host (jinja "{{ nullmailer__relayhost }}"))
      (options (jinja "{{ nullmailer__relayhost_options }}"))
      (auth "True")
      (user (jinja "{{ nullmailer__ldap_self_rdn.split(\"=\")[1] + \"@\" + nullmailer__fqdn }}"))
      (password (jinja "{{ nullmailer__ldap_bindpw }}"))
      (state (jinja "{{ \"present\" if nullmailer__ldap_enabled | bool else \"absent\" }}"))
      (jinja "{{ (nullmailer__relayhost_options | combine({\"host\": nullmailer__relayhost}))
        if (nullmailer__relayhost_options is mapping)
        else ({\"host\": nullmailer__relayhost,
               \"state\": (\"absent\" if nullmailer__ldap_enabled | bool else \"present\"),
               \"options\": nullmailer__relayhost_options}) }}")))
  (nullmailer__remotes (list))
  (nullmailer__maxpause "86400")
  (nullmailer__pausetime "60")
  (nullmailer__sendtimeout "3600")
  (nullmailer__configuration_files (list
      
      (dest "/etc/mailname")
      (content (jinja "{{ nullmailer__mailname }}"))
      
      (dest "/etc/nullmailer/adminaddr")
      (content (jinja "{{ nullmailer__adminaddr
                 if nullmailer__adminaddr is string
                 else nullmailer__adminaddr | join(\",\") }}"))
      
      (dest "/etc/nullmailer/idhost")
      (content (jinja "{{ nullmailer__idhost }}"))
      (mode "0644")
      (state (jinja "{{ \"present\" if nullmailer__idhost else \"absent\" }}"))
      
      (dest "/etc/nullmailer/helohost")
      (content (jinja "{{ nullmailer__helohost }}"))
      (mode "0644")
      (state (jinja "{{ \"present\" if nullmailer__helohost else \"absent\" }}"))
      
      (dest "/etc/nullmailer/defaulthost")
      (content (jinja "{{ nullmailer__defaulthost }}"))
      (mode "0644")
      (state (jinja "{{ \"present\" if nullmailer__defaulthost else \"absent\" }}"))
      
      (dest "/etc/nullmailer/defaultdomain")
      (content (jinja "{{ nullmailer__defaultdomain }}"))
      (mode "0644")
      (state (jinja "{{ \"present\" if nullmailer__defaultdomain else \"absent\" }}"))
      
      (dest "/etc/nullmailer/maxpause")
      (content (jinja "{{ nullmailer__maxpause }}"))
      (mode "0644")
      (state (jinja "{{ \"present\" if nullmailer__maxpause else \"absent\" }}"))
      
      (dest "/etc/nullmailer/pausetime")
      (content (jinja "{{ nullmailer__pausetime }}"))
      (mode "0644")
      (state (jinja "{{ \"present\" if nullmailer__pausetime else \"absent\" }}"))
      
      (dest "/etc/nullmailer/sendtimeout")
      (content (jinja "{{ nullmailer__sendtimeout }}"))
      (mode "0644")
      (state (jinja "{{ \"present\" if nullmailer__sendtimeout else \"absent\" }}"))
      
      (dest "/etc/nullmailer/allmailfrom")
      (content (jinja "{{ nullmailer__allmailfrom }}"))
      (mode "0644")
      (state (jinja "{{ \"present\" if nullmailer__allmailfrom else \"absent\" }}"))))
  (nullmailer__private_configuration_files (list
      
      (dest "/etc/nullmailer/remotes")
      (content (jinja "{{ lookup('template', 'lookup/nullmailer__remotes.j2')
                 | from_yaml | join('\\n') }}"))
      (owner "mail")
      (group "mail")
      (mode "0600")))
  (nullmailer__smtpd "False")
  (nullmailer__smtpd_bind "127.0.0.1")
  (nullmailer__smtpd_bind6 "::1")
  (nullmailer__smtpd_port "25")
  (nullmailer__smtpd_allow (list))
  (nullmailer__ldap__dependent_tasks (list
      
      (name "Create nullmailer account for " (jinja "{{ nullmailer__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ nullmailer__ldap_binddn }}"))
      (objectClass (jinja "{{ nullmailer__ldap_self_object_classes }}"))
      (attributes (jinja "{{ nullmailer__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\"
               if (nullmailer__ldap_enabled | bool and
                   nullmailer__ldap_device_dn | d())
               else \"ignore\" }}"))))
  (nullmailer__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          (jinja "{{ nullmailer__smtpd_port }}")))
      (saddr (jinja "{{ nullmailer__smtpd_allow }}"))
      (accept_any "False")
      (weight "50")
      (role "debops.nullmailer")
      (rule_state (jinja "{{ \"present\"
                    if (nullmailer__deploy_state | d(\"present\") != \"absent\" and
                        nullmailer__smtpd | bool) else \"absent\" }}"))))
  (nullmailer__tcpwrappers__dependent_allow (list
      
      (daemon "sendmail")
      (client (jinja "{{ nullmailer__smtpd_allow }}"))
      (accept_any "False")
      (weight "50")
      (filename "nullmailer_dependent_allow")
      (comment "Allow remote connections to SMTP server")
      (state (jinja "{{ \"present\"
               if (nullmailer__deploy_state | d(\"present\") != \"absent\" and
                   nullmailer__smtpd | bool) else \"absent\" }}"))))
  (nullmailer__dpkg_cleanup__dependent_packages (list
      
      (name "nullmailer")
      (remove_files (list
          (jinja "{{ (nullmailer__configuration_files
             | selectattr(\"dest\", \"defined\")
             | map(attribute=\"dest\") | list)
            | difference(\"/etc/mailname\") }}")
          (jinja "{{ nullmailer__private_configuration_files
            | selectattr(\"dest\", \"defined\")
            | map(attribute=\"dest\") | list }}")
          "/etc/ferm/ferm.d/50_debops.nullmailer_accept_25.conf"
          "/etc/hosts.allow.d/50_nullmailer_dependent_allow"
          "/etc/xinetd.d/nullmailer-smtpd"
          "/etc/xinetd.d/nullmailer-smtpd6"))
      (reload_services (list
          "xinetd"))
      (restart_services (list
          "ferm")))))
