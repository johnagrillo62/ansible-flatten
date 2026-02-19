(playbook "debops/ansible/roles/prosody/defaults/main.yml"
  (prosody__base_packages (list
      "prosody"
      "lua-zlib"
      "lua-sec"
      "prosody-modules"
      (jinja "{{ \"lua-event\" if prosody__use_libevent | bool else [] }}")))
  (prosody__packages (list))
  (prosody__pki (jinja "{{ ansible_local.pki.enabled | d() | bool }}"))
  (prosody__pki_realm_path (jinja "{{ ansible_local.pki.path | d(\"/etc/pki/realms\") }}"))
  (prosody__pki_realm (jinja "{{ ansible_local.pki.realm | d(\"domain\") }}"))
  (prosody__pki_crt_filename (jinja "{{ ansible_local.pki.crt | d(\"default.crt\") }}"))
  (prosody__pki_key_filename (jinja "{{ ansible_local.pki.key | d(\"default.key\") }}"))
  (prosody__pki_hook_name "prosody")
  (prosody__pki_hook_path (jinja "{{ ansible_local.pki.hooks | d(\"/etc/pki/hooks\") }}"))
  (prosody__pki_hook_action "reload")
  (prosody__deploy_state "present")
  (prosody__domain (jinja "{{ ansible_domain }}"))
  (prosody__admins (list))
  (prosody__use_libevent "false")
  (prosody__modules_default (list
      "roster"
      "saslauth"
      "tls"
      "dialback"
      "disco"
      "private"
      "vcard"
      "privacy"
      "version"
      "uptime"
      "time"
      "ping"
      "pep"
      "admin_adhoc"
      "posix"
      "groups"
      "carbons"
      "mam"
      "blocking"
      "smacks"))
  (prosody__modules (jinja "{{ prosody__modules_default }}"))
  (prosody__authentication "internal_plain")
  (prosody__insecure_domains (list))
  (prosody__allow_registration "False")
  (prosody__config_ldap 
    (ldap 
      (hostname "ldap." (jinja "{{ ansible_domain }}"))
      (user 
        (basedn "ou=users,..@TODO")
        (usernamefield "uid"))
      (bind_dn "uid=....,dc=...@TODO")
      (bind_password "lookup..@TODO")
      (use_tls "True")))
  (prosody__default_config_global 
    (admins (jinja "{{ prosody__admins }}"))
    (modules_enabled (jinja "{{ prosody__modules }}"))
    (allow_registration (jinja "{{ prosody__allow_registration }}"))
    (daemonize "True")
    (pidfile "/var/run/prosody/prosody.pid")
    (use_libevent (jinja "{{ prosody__use_libevent }}"))
    (c2s_require_encryption "True")
    (s2s_require_encryption "True")
    (s2s_secure_auth "True")
    (s2s_insecure_domains (jinja "{{ prosody__insecure_domains }}"))
    (authentication (jinja "{{ prosody__authentication }}"))
    (log 
      (info "/var/log/prosody/prosody.log")
      (error "/var/log/prosody/prosody.err")))
  (prosody__config_http_server 
    (http_port (list
        "5280"))
    (http_interface (list
        "*"))
    (https_port (list
        "5281"))
    (https_interface (list
        "*"))
    (https_ssl 
      (certificate (jinja "{{ prosody__pki_realm_path + \"/\" + prosody__pki_realm + \"/\" + prosody__pki_crt_filename }}"))
      (key (jinja "{{ prosody__pki_realm_path + \"/\" + prosody__pki_realm + \"/\" + prosody__pki_key_filename }}"))))
  (prosody__config_global )
  (prosody__group_config_global )
  (prosody__host_config_global )
  (prosody__combined_config_global (jinja "{{ prosody__default_config_global | combine(prosody__config_http_server,
                                                                              prosody__config_ldap if prosody__authentication == \"ldap2\" else {},
                                                                              prosody__config_global,
                                                                              prosody__group_config_global,
                                                                              prosody__host_config_global) }}"))
  (prosody__config_virtual_hosts (list
      
      (name (jinja "{{ ansible_domain }}"))
      (enabled "false")
      (pki_realm "domain")))
  (prosody__http_upload "True")
  (prosody__muc "True")
  (prosody__config_http_upload (list
      
      (domain "upload." (jinja "{{ prosody__domain }}"))
      (params "\"http_upload\"")))
  (prosody__config_muc (list
      
      (domain "conference." (jinja "{{ prosody__domain }}"))
      (params "\"muc\"")))
  (prosody__default_config_components (jinja "{{ (prosody__config_http_upload if prosody__http_upload | bool else [])
                                      + (prosody__config_muc if prosody__muc | bool else []) }}"))
  (prosody__config_components (list))
  (prosody__group_config_components (list))
  (prosody__host_config_components (list))
  (prosody__combined_config_components (jinja "{{ prosody__default_config_components
                                         + prosody__config_components
                                         + prosody__group_config_components
                                         + prosody__host_config_components }}"))
  (prosody__ferm__dependent_rules (list
      
      (type "accept")
      (dport (list
          "5222"))
      (accept_any "True")
      (weight "40")
      (by_role "prosody")
      (name "prosody-xmpp-client")
      (multiport "True")
      (rule_state (jinja "{{ prosody__deploy_state }}"))
      
      (type "accept")
      (dport (list
          "5269"))
      (accept_any "True")
      (weight "40")
      (by_role "prosody")
      (name "prosody-xmpp-server")
      (multiport "True")
      (rule_state (jinja "{{ prosody__deploy_state }}"))
      
      (type "accept")
      (dport (list
          "5280"
          "5281"))
      (accept_any "True")
      (weight "40")
      (by_role "prosody")
      (name "prosody-http")
      (multiport "True")
      (rule_state (jinja "{{ prosody__deploy_state }}")))))
