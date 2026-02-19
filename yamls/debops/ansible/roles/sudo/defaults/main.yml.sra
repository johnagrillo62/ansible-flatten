(playbook "debops/ansible/roles/sudo/defaults/main.yml"
  (sudo__enabled "True")
  (sudo__base_packages (jinja "{{ [\"sudo-ldap\"]
                         if sudo__ldap_enabled | bool
                         else [\"sudo\"] }}"))
  (sudo__packages (list))
  (sudo__logind_session (jinja "{{ True if (ansible_service_mgr == \"systemd\") else False }}"))
  (sudo__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (sudo__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (sudo__ldap_self_rdn "uid=sudo")
  (sudo__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (sudo__ldap_self_attributes 
    (uid (jinja "{{ sudo__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ sudo__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"sudo\" service to access the LDAP directory"))
  (sudo__ldap_binddn (jinja "{{ ([sudo__ldap_self_rdn] + sudo__ldap_device_dn) | join(\",\") }}"))
  (sudo__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                               + sudo__ldap_binddn | to_uuid + \".password length=32\"))
                       if sudo__ldap_enabled | bool
                       else \"\" }}"))
  (sudo__sudoers (list))
  (sudo__group_sudoers (list))
  (sudo__host_sudoers (list))
  (sudo__dependent_sudoers (list))
  (sudo__combined_sudoers (jinja "{{ sudo__sudoers
                            + sudo__group_sudoers
                            + sudo__host_sudoers
                            + sudo__dependent_sudoers }}"))
  (sudo__ldap_enabled (jinja "{{ True
                        if (ansible_local | d() and ansible_local.ldap | d() and
                            (ansible_local.ldap.posix_enabled | d()) | bool and not
                            (ansible_local.sssd | d() and ansible_local.sssd.installed | d()) | bool)
                        else False }}"))
  (sudo__ldap_default_configuration (list
      
      (name "sudoers_base")
      (comment "The base DN to use when performing \"sudo\" LDAP queries.")
      (value (jinja "{{ ([\"ou=SUDOers\"] + sudo__ldap_base_dn) | join(\",\") }}"))
      
      (name "uri")
      (comment "The location at which the LDAP server(s) should be reachable.")
      (value (jinja "{{ ansible_local.ldap.uri | d(\"\") }}"))
      
      (name "ssl")
      (comment "SSL options")
      (value (jinja "{{ \"start_tls\"
               if (ansible_local | d() and ansible_local.ldap | d() and
                   (ansible_local.ldap.start_tls | d()) | bool)
               else \"on\" }}"))
      
      (name "tls_reqcert")
      (value "demand")
      
      (name "tls_cacert")
      (value "/etc/ssl/certs/ca-certificates.crt")
      
      (name "binddn")
      (comment "The \"sudo\" service LDAP credentials used to bind to the directory.")
      (value (jinja "{{ sudo__ldap_binddn }}"))
      
      (name "bindpw")
      (value (jinja "{{ sudo__ldap_bindpw }}"))))
  (sudo__ldap_configuration (list))
  (sudo__ldap_group_configuration (list))
  (sudo__ldap_host_configuration (list))
  (sudo__ldap_combined_configuration (jinja "{{ sudo__ldap_default_configuration
                                       + sudo__ldap_configuration
                                       + sudo__ldap_group_configuration
                                       + sudo__ldap_host_configuration }}"))
  (sudo__ldap__dependent_tasks (list
      
      (name "Create sudo account for " (jinja "{{ sudo__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ sudo__ldap_binddn }}"))
      (objectClass (jinja "{{ sudo__ldap_self_object_classes }}"))
      (attributes (jinja "{{ sudo__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\"
               if sudo__ldap_enabled | bool
               else \"ignore\" }}")))))
