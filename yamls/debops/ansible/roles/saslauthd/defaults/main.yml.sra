(playbook "debops/ansible/roles/saslauthd/defaults/main.yml"
  (saslauthd__default_mechanism (jinja "{{ \"ldap\" if saslauthd__ldap_device_dn | d() else \"pam\" }}"))
  (saslauthd__base_packages (list
      "sasl2-bin"
      "libsasl2-modules"))
  (saslauthd__packages (list))
  (saslauthd__default_instances (list
      
      (name "smtpd")
      (group "postfix")
      (description "Postfix SASL Authentication Daemon")
      (config_path "/etc/postfix/sasl/smtpd.conf")
      (config_group "postfix")
      (config_raw "pwcheck_method: saslauthd
mech_list: PLAIN LOGIN
")
      (socket_path "/var/spool/postfix/var/run/saslauthd")
      (socket_group "postfix")
      (ldap_profile "smtpd")
      (state (jinja "{{ \"present\"
               if ((ansible_local | d() and ansible_local.postfix | d() and
                    (ansible_local.postfix.installed | d()) | bool) or
                   (\"debops_service_postfix\" in group_names))
               else \"ignore\" }}"))))
  (saslauthd__instances (list))
  (saslauthd__group_instances (list))
  (saslauthd__host_instances (list))
  (saslauthd__dependent_instances (list))
  (saslauthd__combined_instances (jinja "{{ q(\"flattened\", (saslauthd__default_instances
                                                  + saslauthd__instances
                                                  + saslauthd__group_instances
                                                  + saslauthd__host_instances
                                                  + saslauthd__dependent_instances)) }}"))
  (saslauthd__ldap_enabled (jinja "{{ ansible_local.ldap.enabled
                             if (ansible_local | d() and ansible_local.ldap | d() and
                                 ansible_local.ldap.enabled is defined)
                             else False }}"))
  (saslauthd__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (saslauthd__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (saslauthd__ldap_self_rdn "uid=saslauthd")
  (saslauthd__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (saslauthd__ldap_self_attributes 
    (uid (jinja "{{ saslauthd__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ saslauthd__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"saslauthd\" service to access the LDAP directory"))
  (saslauthd__ldap_binddn (jinja "{{ ([saslauthd__ldap_self_rdn] + saslauthd__ldap_device_dn) | join(\",\") }}"))
  (saslauthd__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                    + saslauthd__ldap_binddn | to_uuid + \".password length=32\"))
                            if saslauthd__ldap_enabled | bool
                            else \"\" }}"))
  (saslauthd__ldap_default_profiles (list
      
      (name "global")
      (state (jinja "{{ \"present\" if saslauthd__ldap_device_dn | d() else \"ignore\" }}"))
      (options (list
          
          (name "ldap_servers")
          (value (jinja "{{ ansible_local.ldap.uri | d(\"\") }}"))
          
          (name "ldap_bind_dn")
          (value (jinja "{{ saslauthd__ldap_binddn }}"))
          
          (name "ldap_password")
          (value (jinja "{{ saslauthd__ldap_bindpw }}"))
          
          (name "ldap_search_base")
          (value (jinja "{{ ([\"ou=People\"] + saslauthd__ldap_base_dn) | join(\",\") }}"))
          
          (name "ldap_filter")
          (value "(& (objectClass=inetOrgPerson) (uid=%u) )")
          
          (name "ldap_scope")
          (value "sub")
          
          (name "ldap_start_tls")
          (value "yes")
          
          (name "ldap_tls_check_peer")
          (value "yes")
          
          (name "ldap_tls_cacert_file")
          (value "/etc/ssl/certs/ca-certificates.crt")))
      
      (name "slapd")
      (state (jinja "{{ \"present\"
               if (saslauthd__ldap_device_dn | d() and
                   ((ansible_local | d() and ansible_local.slapd | d() and
                     (ansible_local.slapd.installed | d()) | bool) or
                    (\"debops_service_slapd\" in group_names)))
               else \"ignore\" }}"))
      (options (list
          
          (name "ldap_servers")
          (value (jinja "{{ ansible_local.ldap.uri | d(\"\") }}"))
          
          (name "ldap_bind_dn")
          (value (jinja "{{ saslauthd__ldap_binddn }}"))
          
          (name "ldap_password")
          (value (jinja "{{ saslauthd__ldap_bindpw }}"))
          
          (name "ldap_search_base")
          (value (jinja "{{ saslauthd__ldap_base_dn | join(\",\") }}"))
          
          (name "ldap_filter")
          (value "(| (& (objectClass=inetOrgPerson) (uid=%u) ) (& (objectClass=account) (uid=%U) (host=%r) ) )")
          
          (name "ldap_scope")
          (value "sub")
          
          (name "ldap_start_tls")
          (value "yes")
          
          (name "ldap_tls_check_peer")
          (value "yes")
          
          (name "ldap_tls_cacert_file")
          (value "/etc/ssl/certs/ca-certificates.crt")))
      
      (name "smtpd")
      (state (jinja "{{ \"present\"
               if (saslauthd__ldap_device_dn | d() and
                   ((ansible_local | d() and ansible_local.postfix | d() and
                     (ansible_local.postfix.installed | d()) | bool) or
                    (\"debops_service_postfix\" in group_names)))
               else \"ignore\" }}"))
      (options (list
          
          (name "ldap_servers")
          (value (jinja "{{ ansible_local.ldap.uri | d(\"\") }}"))
          
          (name "ldap_bind_dn")
          (value (jinja "{{ saslauthd__ldap_binddn }}"))
          
          (name "ldap_password")
          (value (jinja "{{ saslauthd__ldap_bindpw }}"))
          
          (name "ldap_search_base")
          (value (jinja "{{ saslauthd__ldap_base_dn | join(\",\") }}"))
          
          (name "ldap_filter")
          (value "(| (& (objectClass=mailRecipient) (| (uid=%u) (mailAddress=%U@%r) (mailAlternateAddress=%U@%r) ) (| (authorizedService=all) (authorizedService=mail:send) ) ) (& (objectClass=account) (uid=%U) (host=%r) (| (authorizedService=all) (authorizedService=mail:send) ) ) )")
          
          (name "ldap_scope")
          (value "sub")
          
          (name "ldap_start_tls")
          (value "yes")
          
          (name "ldap_tls_check_peer")
          (value "yes")
          
          (name "ldap_tls_cacert_file")
          (value "/etc/ssl/certs/ca-certificates.crt")))))
  (saslauthd__ldap_profiles (list))
  (saslauthd__ldap_group_profiles (list))
  (saslauthd__ldap_host_profiles (list))
  (saslauthd__ldap_combined_profiles (jinja "{{ saslauthd__ldap_default_profiles
                                       + saslauthd__ldap_profiles
                                       + saslauthd__ldap_group_profiles
                                       + saslauthd__ldap_host_profiles }}"))
  (saslauthd__ldap__dependent_tasks (list
      
      (name "Create saslauthd account for " (jinja "{{ saslauthd__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ saslauthd__ldap_binddn }}"))
      (objectClass (jinja "{{ saslauthd__ldap_self_object_classes }}"))
      (attributes (jinja "{{ saslauthd__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\" if saslauthd__ldap_device_dn | d() else \"ignore\" }}")))))
