(playbook "debops/ansible/roles/sssd/defaults/main.yml"
  (sssd__base_packages (list
      (list
        "sssd"
        "libnss-sss"
        "libsss-sudo"
        "libpam-sss")))
  (sssd__packages (list))
  (sssd__mkhomedir_umask (jinja "{{ ansible_local.core.homedir_umask | d(\"0027\") }}"))
  (sssd__ldap_enabled (jinja "{{ ansible_local.ldap.enabled
                        if (ansible_local | d() and ansible_local.ldap | d() and
                            ansible_local.ldap.enabled is defined)
                        else False }}"))
  (sssd__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (sssd__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (sssd__ldap_self_rdn "uid=sssd")
  (sssd__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (sssd__ldap_self_attributes 
    (uid (jinja "{{ sssd__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ sssd__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"sssd\" service to access the LDAP directory"))
  (sssd__ldap_binddn (jinja "{{ ([sssd__ldap_self_rdn] + sssd__ldap_device_dn) | join(\",\") }}"))
  (sssd__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                               + sssd__ldap_binddn | to_uuid + \".password length=32\"))
                       if sssd__ldap_enabled | bool
                       else \"\" }}"))
  (sssd__ldap_posix_urns (jinja "{{ (ansible_local.ldap.urn_patterns
                            if (ansible_local.ldap.urn_patterns | d())
                            else [])
                           | map(\"regex_replace\", \"^(.*)$\", \"(host=posix:urn:\\1)\")
                           | list }}"))
  (sssd__ldap_host_filter "(| (host=posix:all) (host=posix:" (jinja "{{ ansible_fqdn }}") ") (host=posix:\\2a." (jinja "{{ ansible_domain }}") ") " (jinja "{{ sssd__ldap_posix_urns | join(\" \") }}") " )")
  (sssd__default_configuration (list
      
      (section "sssd")
      (title "Global directives")
      (options (list
          
          (name "config_file_version")
          (comment "Indicates the syntax of the config file, SSSD 0.6.0 and later uses version 2")
          (value "2")
          
          (name "domains")
          (comment "A domain is a label for a source of user information, sssd supports multiple domains")
          (value "default")
          
          (name "services")
          (comment "Services to offer (nss, pam, sudo, autofs, ssh, pac, ifp)")
          (value (list
              "nss"
              "pam"
              "sudo"
              "ssh"))
          (state (jinja "{{ \"present\" if ansible_distribution_release in [\"stretch\", \"buster\", \"bionic\"] else \"ignore\" }}"))
          
          (name "debug_level")
          (comment "Note that debug level is a bitmap and only applies to a given section
of the config file, so you might want to set it in other sections as
well if you want to enable debugging (see sssd.conf(5)).
")
          (value "0x0770")
          (state "comment")))
      
      (section "nss")
      (title "Name Service Switch directives")
      (options (list
          
          (name "filter_users")
          (comment "Users which should be excluded from being fetched via sss (default: root)")
          (value "root")
          (state "comment")
          
          (name "filter_groups")
          (comment "Groups which should be excluded from being fetched via sss (default: root)")
          (value "root")
          (state "comment")))
      
      (section "pam")
      (title "Pluggable Authentication Modules directives")
      (options (list
          
          (name "offline_credentials_expiration")
          (comment "How long should offline logins be allowed (in days since last successful online login, default: 0 - no limit)")
          (value "0")
          (state "comment")
          
          (name "offline_failed_login_attempts")
          (comment "How many failed offline login attempts are allowed")
          (value "5")
          
          (name "offline_failed_login_delay")
          (comment "Delay (in minutes) between login attempts after offline_failed_login_attempts has been reached")
          (value "1")))
      
      (section "sudo")
      (title "Sudo directives")
      (options (list
          
          (name "sudo_timed")
          (comment "Whether to evaluate the sudoNotBefore and sudoNotAfter attributes")
          (value "False")
          (state "comment")))
      
      (section "ssh")
      (title "Secure SHell directives")
      (options (list
          
          (name "ssh_hash_known_hosts")
          (comment "Whether to hash the managed known_hosts file")
          (value "True")
          (state "comment")
          
          (name "ssh_known_hosts_timeout")
          (comment "How many seconds to keep a host in the managed known_hosts file")
          (value "180")
          (state "comment")))
      
      (section "domain/default")
      (title "Default domain directives")
      (options (list
          
          (name "id_provider")
          (comment "The identification provider to use for the domain. Possible providers
include e.g. ldap, ipa and ad (see the corresponding sssd-* man pages).
")
          (value "ldap")
          
          (name "auth_provider")
          (comment "The authentication provider to use for the domain. Possible providers
include e.g. ldap, krb5, ipa and ad (see the corresponding sssd-* man
pages).
")
          (value "ldap")
          
          (name "chpass_provider")
          (comment "The password change provider to use for the domain. Possible providers
include e.g. ldap, krb5, ipa and ad (see the corresponding sssd-* man
pages).
")
          (value "ldap")
          
          (name "sudo_provider")
          (comment "The SUDO rules provider to use for the domain. Possible providers
include e.g. ldap, ipa and ad (see the corresponding sssd-* man
pages).
")
          (value "ldap")
          
          (name "access_provider")
          (comment "The access control provider to use for the domain. Possible providers
include e.g. permit, deny, ldap, ipa, ad and simple (see the
corresponding sssd-* man pages).
")
          (value "ldap")
          
          (name "ldap_access_order")
          (comment "SSSD has builtin support for checking authorizedServices and host
attributes, but it looks for \"*\" rather than \"all\" or \"posix:all\"
as in DebOps, and it also only checks the attributes for posixAccount
and not posixGroup entries, therefore the authorized_service and host
checks cannot be enabled by default.
")
          (value "pwd_expire_policy_renew")
          
          (name "ldap_uri")
          (comment "The location at which the LDAP server(s) should be reachable.")
          (value (jinja "{{ ansible_local.ldap.uri | d(\"\") }}"))
          
          (name "ldap_default_bind_dn")
          (comment "The DN to bind with for normal lookups.")
          (value (jinja "{{ sssd__ldap_binddn }}"))
          
          (name "ldap_default_authtok")
          (value (jinja "{{ sssd__ldap_bindpw }}"))
          
          (name "ldap_schema")
          (comment "Specifies the schema used on the LDAP server (rfc2307, rfc2307bis, ipa, ad)")
          (value "rfc2307bis")
          
          (name "ldap_pwd_policy")
          (comment "Which policy should be used to evaluate password expiration
(none, shadow, mit_kerberos). Note that if you enable this, users
without shadowAccount attributes *will* be denied access.
")
          (value "shadow")
          (state "comment")
          
          (name "ldap_connection_expire_timeout")
          (comment "The idle timelimit for connections with the LDAP server. This should be
lower than the server's olcIdleTimeout (default: 900).
")
          (value "600")
          
          (name "min_id")
          (comment "First valid UID/GID number expected to be in the LDAP directory.
UIDs/GIDs lower than this value will be ignored.
")
          (value (jinja "{{ ansible_local.ldap.uid_gid_min | d(\"10000\") }}"))
          
          (name "max_id")
          (comment "Last valid UID/GID number expected to be in the LDAP directory.
UIDs/GIDs higher than this value will be ignored (0 = no limit).
")
          (value (jinja "{{ ansible_local.ldap.uid_gid_max | d(\"0\") }}"))
          
          (name "cache_credentials")
          (comment "Whether user credentials should also be cached (in hashed form) in a
local cache in order to allow offline logins (see also the
\"offline_credentials_expiration\" parameter in the [pam] section).
")
          (value "True")
          
          (name "enumerate")
          (comment "Enumeration means that sssd will download and cache ALL users and
groups from the remote server. This means that they will be available
in case of sudden network outages, etc, but is not suitable for
large environments.
")
          (value "False")
          
          (name "ldap_enumeration_refresh_timeout")
          (comment "Specifies how often re-enumeration should be performed (in seconds).")
          (value "300")
          
          (name "ldap_id_use_start_tls")
          (comment "SSL options")
          (value (jinja "{{ True
                  if (ansible_local | d() and ansible_local.ldap | d() and
                      (ansible_local.ldap.start_tls | d()) | bool)
                  else False }}"))
          
          (name "ldap_tls_reqcert")
          (value "demand")
          
          (name "ldap_tls_cacert")
          (value "/etc/ssl/certs/ca-certificates.crt")
          
          (name "ldap_group_name")
          (comment "Use the 'gid' attribute instead of 'cn' as the POSIX group name.
")
          (value "gid")
          
          (name "ldap_search_base")
          (comment "The search base that will be used for queries. \"ldap_search_base\"
defines the default search base which will be used unless a more
specific \"ldap_*_search_base\" has been defined.
Format: search_base[?scope?[filter][?search_base?scope?[filter]]*]
")
          (value (jinja "{{ sssd__ldap_base_dn | join(\",\") }}"))
          
          (name "ldap_user_search_base")
          (value (jinja "{{ sssd__ldap_base_dn | join(\",\") + \"?subtree?\" + sssd__ldap_host_filter }}"))
          
          (name "ldap_group_search_base")
          (value (jinja "{{ sssd__ldap_base_dn | join(\",\") + \"?subtree?\" + sssd__ldap_host_filter }}"))
          
          (name "ldap_sudo_search_base")
          (value (jinja "{{ sssd__ldap_base_dn | join(\",\") + \"?subtree?\" + \"\" }}"))
          (state "comment")))))
  (sssd__configuration (list))
  (sssd__group_configuration (list))
  (sssd__host_configuration (list))
  (sssd__combined_configuration (jinja "{{ sssd__default_configuration
                                   + sssd__configuration
                                   + sssd__group_configuration
                                   + sssd__host_configuration }}"))
  (sssd__ldap__dependent_tasks (list
      
      (name "Create sssd account for " (jinja "{{ sssd__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ sssd__ldap_binddn }}"))
      (objectClass (jinja "{{ sssd__ldap_self_object_classes }}"))
      (attributes (jinja "{{ sssd__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\"
               if ((ansible_local.ldap.posix_enabled | d()) | bool and
                   sssd__ldap_device_dn | d())
               else \"ignore\" }}"))))
  (sssd__nsswitch__dependent_services (list
      "sss")))
