(playbook "debops/ansible/roles/nslcd/defaults/main.yml"
  (nslcd__base_packages (list
      (list
        "libpam-ldapd"
        "libnss-ldapd"
        "nslcd"
        "openssl"
        "ca-certificates")
      (jinja "{{ \"nslcd-utils\"
        if (ansible_local | d() and ansible_local.python | d() and
            (ansible_local.python.installed2 | d()) | bool)
        else [] }}")))
  (nslcd__packages (list))
  (nslcd__user "nslcd")
  (nslcd__group "nslcd")
  (nslcd__mkhomedir_umask (jinja "{{ ansible_local.core.homedir_umask | d(\"0027\") }}"))
  (nslcd__ldap_enabled (jinja "{{ ansible_local.ldap.enabled
                         if (ansible_local | d() and ansible_local.ldap | d() and
                             ansible_local.ldap.enabled is defined)
                         else False }}"))
  (nslcd__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (nslcd__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (nslcd__ldap_self_rdn (jinja "{{ \"uid=\" + nslcd__user }}"))
  (nslcd__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (nslcd__ldap_self_attributes 
    (uid (jinja "{{ nslcd__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ nslcd__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"nslcd\" service to access the LDAP directory"))
  (nslcd__ldap_binddn (jinja "{{ ([nslcd__ldap_self_rdn] + nslcd__ldap_device_dn) | join(\",\") }}"))
  (nslcd__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                                + nslcd__ldap_binddn | to_uuid + \".password length=32\"))
                        if nslcd__ldap_enabled | bool
                        else \"\" }}"))
  (nslcd__ldap_posix_urns (jinja "{{ (ansible_local.ldap.urn_patterns
                             if (ansible_local.ldap.urn_patterns | d())
                             else [])
                            | map(\"regex_replace\", \"^(.*)$\", \"(host=posix:urn:\\1)\")
                            | list }}"))
  (nslcd__ldap_host_filter "(| (host=posix:all) (host=posix:" (jinja "{{ ansible_fqdn }}") ") (host=posix:\\2a." (jinja "{{ ansible_domain }}") ") " (jinja "{{ nslcd__ldap_posix_urns | join(\" \") }}") " )")
  (nslcd__idle_timelimit "600")
  (nslcd__default_configuration (list
      
      (name "uid")
      (comment "The user and group nslcd should run as.")
      (value (jinja "{{ nslcd__user }}"))
      
      (name "gid")
      (value (jinja "{{ nslcd__group }}"))
      
      (name "uri")
      (comment "The location at which the LDAP server(s) should be reachable.")
      (value (jinja "{{ ansible_local.ldap.uri | d(\"\") }}"))
      
      (name "idle_timelimit")
      (comment "The idle timelimit for connections with the LDAP server.")
      (value (jinja "{{ nslcd__idle_timelimit }}"))
      
      (name "base")
      (comment "The search base that will be used for all queries.")
      (value (jinja "{{ nslcd__ldap_base_dn | join(\",\") }}"))
      
      (name "ldap_version")
      (comment "The LDAP protocol version to use.")
      (value "3")
      (state "comment")
      
      (name "binddn")
      (comment "The DN to bind with for normal lookups.")
      (value (jinja "{{ nslcd__ldap_binddn }}"))
      
      (name "bindpw")
      (value (jinja "{{ nslcd__ldap_bindpw }}"))
      
      (name "rootpwmoddn")
      (comment "The DN used for password modifications by root.")
      (value "cn=admin,dc=example,dc=com")
      (state "comment")
      
      (name "ssl")
      (comment "SSL options")
      (value (jinja "{{ \"start_tls\"
               if (ansible_local | d() and ansible_local.ldap | d() and
                   (ansible_local.ldap.start_tls | d()) | bool)
               else \"on\" }}"))
      
      (name "tls_reqcert")
      (value "demand")
      
      (name "tls_cacertfile")
      (value "/etc/ssl/certs/ca-certificates.crt")
      
      (name "scope")
      (comment "The search scope.")
      (value "sub")
      (state "comment")
      
      (name "nss_min_uid")
      (comment "First valid UID/GID number expected to be in the LDAP directory.
UIDs/GIDs lower than this value will be ignored.
")
      (value (jinja "{{ ansible_local.ldap.uid_gid_min | d(\"10000\") }}"))
      
      (name "map_group_id")
      (comment "Use the 'gid' attribute instead of 'cn' as the POSIX group name.
")
      (option "map")
      (map "group")
      (value "cn gid")
      
      (name "filter_passwd_group")
      (raw "filter passwd (& (objectClass=posixAccount) " (jinja "{{ nslcd__ldap_host_filter }}") " )
filter group  (& (objectClass=posixGroupId) " (jinja "{{ nslcd__ldap_host_filter }}") " )
filter shadow (& (objectClass=shadowAccount) " (jinja "{{ nslcd__ldap_host_filter }}") " )
")
      (comment "Limit which UNIX accounts and groups are present on a host")))
  (nslcd__configuration (list))
  (nslcd__group_configuration (list))
  (nslcd__host_configuration (list))
  (nslcd__combined_configuration (jinja "{{ nslcd__default_configuration
                                   + nslcd__configuration
                                   + nslcd__group_configuration
                                   + nslcd__host_configuration }}"))
  (nslcd__ldap__dependent_tasks (list
      
      (name "Create nslcd account for " (jinja "{{ nslcd__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ nslcd__ldap_binddn }}"))
      (objectClass (jinja "{{ nslcd__ldap_self_object_classes }}"))
      (attributes (jinja "{{ nslcd__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\"
               if ((ansible_local.ldap.posix_enabled | d()) | bool and
                   nslcd__ldap_device_dn | d())
               else \"ignore\" }}"))))
  (nslcd__nsswitch__dependent_services (list
      "ldap")))
