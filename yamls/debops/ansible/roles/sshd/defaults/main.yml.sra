(playbook "debops/ansible/roles/sshd/defaults/main.yml"
  (sshd__base_packages (list
      "openssh-server"
      "openssh-client"))
  (sshd__recommended_packages (jinja "{{ [\"openssh-blacklist\", \"openssh-blacklist-extra\"]
                                if (ansible_distribution_release in
                                    [\"trusty\", \"xenial\"]) else [] }}"))
  (sshd__optional_packages (list
      "molly-guard"))
  (sshd__ldap_packages (jinja "{{ [\"ldap-utils\"]
                         if (sshd__authorized_keys_lookup | bool and
                             (\"ldap\" in sshd__authorized_keys_lookup_type))
                         else [] }}"))
  (sshd__packages (list))
  (sshd__version (jinja "{{ ansible_local.sshd.version | d(\"0.0\") }}"))
  (sshd__whitelist (list))
  (sshd__group_whitelist (list))
  (sshd__host_whitelist (list))
  (sshd__allow (list))
  (sshd__group_allow (list))
  (sshd__host_allow (list))
  (sshd__tcpwrappers_default "ALL")
  (sshd__ferm_weight "30")
  (sshd__ferm_limit "True")
  (sshd__ferm_limit_seconds (jinja "{{ (60 * 5) }}"))
  (sshd__ferm_limit_hits "8")
  (sshd__ferm_limit_chain "filter-ssh")
  (sshd__ferm_limit_target "REJECT")
  (sshd__ferm_ports (jinja "{{ sshd__ports
                      if ((ansible_local.sshd.socket_activation | d(\"disabled\")) == \"disabled\")
                      else [\"22\"] }}"))
  (sshd__ferm_interface (list))
  (sshd__ports (list
      "22"))
  (sshd__host_keys (list
      "ed25519"
      "rsa"
      "ecdsa"))
  (sshd__trusted_user_ca_keys (list))
  (sshd__trusted_user_ca_keys_file "/etc/ssh/trusted-user-ca-keys.pem")
  (sshd__scan_for_host_certs "False")
  (sshd__original_configuration (list
      
      (name "Include_sshd_config.d")
      (option "Include")
      (value "/etc/ssh/sshd_config.d/*.conf")
      (state (jinja "{{ \"absent\" if ansible_distribution_release in [\"stretch\", \"buster\"] else \"present\" }}"))
      
      (name "Port")
      (value "22")
      (state "init")
      (separator "True")
      
      (name "AddressFamily")
      (value "any")
      (state "init")
      
      (name "ListenAddress_ipv4")
      (option "ListenAddress")
      (value "0.0.0.0")
      (state "init")
      
      (name "ListenAddress_ipv6")
      (option "ListenAddress")
      (value "::")
      (state "init")
      
      (name "HostKey")
      (raw "HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
")
      (state "init")
      (separator "True")
      
      (name "RekeyLimit")
      (comment "Ciphers and keyring")
      (value "default none")
      (state "init")
      
      (name "SyslogFacility")
      (comment "Logging")
      (value "AUTH")
      (state "init")
      
      (name "LogLevel")
      (value "INFO")
      (state "init")
      
      (name "LoginGraceTime")
      (comment "Authentication")
      (value "2m")
      (state "init")
      
      (name "PermitRootLogin")
      (value "prohibit-password")
      (state "init")
      
      (name "StrictModes")
      (value "True")
      (state "init")
      
      (name "MaxAuthTries")
      (value "6")
      (state "init")
      
      (name "MaxSessions")
      (value "10")
      (state "init")
      
      (name "PubkeyAuthentication")
      (value "True")
      (state "init")
      (separator "True")
      
      (name "AuthorizedKeysFile")
      (comment "Expect .ssh/authorized_keys2 to be disregarded by default in future.")
      (value (list
          ".ssh/authorized_keys"
          ".ssh/authorized_keys2"))
      (state "init")
      
      (name "AuthorizedPrincipalsFile")
      (value "none")
      (state "init")
      (separator "True")
      
      (name "AuthorizedKeysCommand")
      (value "none")
      (state "init")
      (separator "True")
      
      (name "AuthorizedKeysCommandUser")
      (value "nobody")
      (state "init")
      
      (name "HostbasedAuthentication")
      (comment "For this to work you will also need host keys in /etc/ssh/ssh_known_hosts")
      (value "False")
      (state "init")
      
      (name "IgnoreUserKnownHosts")
      (comment "Change to yes if you don't trust ~/.ssh/known_hosts for
HostbasedAuthentication
")
      (value "False")
      (state "init")
      
      (name "IgnoreRhosts")
      (comment "Don't read the user's ~/.rhosts and ~/.shosts files")
      (value "True")
      (state "init")
      
      (name "PasswordAuthentication")
      (comment "To disable tunneled clear text passwords, change to no here!")
      (value "True")
      (state "init")
      
      (name "ChallengeResponseAuthentication")
      (comment "Change to yes to enable challenge-response passwords (beware issues with
some PAM modules and threads). From openssh-server version 8.7, this option
is deprecated and is an alias of KbdInteractiveAuthentication.
")
      (value "False")
      (state "init")
      
      (name "KbdInteractiveAuthentication")
      (comment "Change to yes to enable challenge-response passwords (beware issues with
some PAM modules and threads)
")
      (value "False")
      (state "init")
      
      (name "PermitEmptyPasswords")
      (value "False")
      (state "init")
      
      (name "KerberosAuthentication")
      (comment "Kerberos options")
      (value "False")
      (state "init")
      
      (name "KerberosOrLocalPasswd")
      (value "True")
      (state "init")
      
      (name "KerberosTicketCleanup")
      (value "True")
      (state "init")
      
      (name "KerberosGetAFSToken")
      (value "False")
      (state "init")
      
      (name "GSSAPIAuthentication")
      (comment "GSSAPI options")
      (value "False")
      (state "init")
      
      (name "GSSAPICleanupCredentials")
      (value "True")
      (state "init")
      
      (name "GSSAPIStrictAcceptorCheck")
      (value "True")
      (state "init")
      
      (name "GSSAPIKeyExchange")
      (value "False")
      (state "init")
      
      (name "UsePAM")
      (comment "Set this to 'yes' to enable PAM authentication, account processing,
and session processing. If this is enabled, PAM authentication will
be allowed through the ChallengeResponseAuthentication and
PasswordAuthentication.  Depending on your PAM configuration,
PAM authentication via ChallengeResponseAuthentication may bypass
the setting of \"PermitRootLogin without-password\".
If you just want the PAM account and session checks to run without
PAM authentication, then enable this but set PasswordAuthentication
and ChallengeResponseAuthentication to 'no'.
")
      (value "True")
      
      (name "AllowAgentForwarding")
      (value "True")
      (state "init")
      (separator "True")
      
      (name "AllowTcpForwarding")
      (value "True")
      (state "init")
      
      (name "GatewayPorts")
      (value "False")
      (state "init")
      
      (name "X11Forwarding")
      (value "True")
      
      (name "X11DisplayOffset")
      (value "10")
      (state "init")
      
      (name "X11UseLocalhost")
      (value "True")
      (state "init")
      
      (name "PermitTTY")
      (value "True")
      (state "init")
      
      (name "PrintMotd")
      (value "False")
      
      (name "PrintLastLog")
      (value "True")
      (state "init")
      
      (name "TCPKeepAlive")
      (value "True")
      (state "init")
      
      (name "PermitUserEnvironment")
      (value "False")
      (state "init")
      
      (name "Compression")
      (value "delayed")
      (state "init")
      
      (name "ClientAliveInterval")
      (value "0")
      (state "init")
      
      (name "ClientAliveCountMax")
      (value "3")
      (state "init")
      
      (name "UseDNS")
      (value "False")
      (state "init")
      
      (name "PidFile")
      (value "/var/run/sshd.pid")
      (state "init")
      
      (name "MaxStartups")
      (value "10:30:100")
      (state "init")
      
      (name "PermitTunnel")
      (value "False")
      (state "init")
      
      (name "ChrootDirectory")
      (value "none")
      (state "init")
      
      (name "VersionAddendum")
      (value "none")
      (state "init")
      
      (name "Banner")
      (comment "no default banner path")
      (value "none")
      (state "init")
      
      (name "AcceptEnv")
      (comment "Allow client to pass locale environment variables")
      (value (list
          "LANG"
          "LC_*"))
      
      (name "Subsystem_sftp")
      (option "Subsystem")
      (comment "override default of no subsystems")
      (value "sftp   /usr/lib/openssh/sftp-server")
      
      (name "Match_user_anoncvs")
      (option "Match")
      (comment "Example of overriding settings on a per-user basis")
      (value (list
          "User anoncvs"))
      (config "X11Forwarding no
AllowTcpForwarding no
PermitTTY no
ForceCommand cvs server
")
      (state "comment")))
  (sshd__default_configuration (list
      
      (name "Port")
      (raw (jinja "{% for port in sshd__ports %}") "
" (jinja "{{ 'Port {}'.format(port) }}") "
" (jinja "{% endfor %}") "
")
      (state (jinja "{{ \"ignore\"
               if (sshd__ports | length == 1 and
                   sshd__ports | first | string == \"22\")
               else (\"ignore\"
                     if ((ansible_local.sshd.socket_activation | d(\"disabled\")) == \"enabled\")
                     else \"present\") }}"))
      
      (name "HostKey")
      (raw (jinja "{% for hostkey in sshd__host_keys %}") "
" (jinja "{% if ('ssh_host_' + hostkey + '_key') in sshd__register_host_keys.stdout_lines %}") "
" (jinja "{{ 'HostKey /etc/ssh/ssh_host_{}_key'.format(hostkey) }}") "
" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "
")
      (state "present")
      
      (name "HostCertificate")
      (raw (jinja "{% if (sshd__register_host_certs is defined and
             \"stdout_lines\" in sshd__register_host_certs) %}") "
" (jinja "{% for cert in sshd__register_host_certs.stdout_lines %}") "
" (jinja "{% set sshd__key_matching_cert = cert | regex_replace('-cert', '') %}") "
" (jinja "{% set sshd__key_matching_host_keys = sshd__key_matching_cert | regex_replace('ssh_host_(\\w+)_key', '\\\\1') %}") "
" (jinja "{% if sshd__key_matching_cert in sshd__register_host_keys.stdout_lines and sshd__key_matching_host_keys in sshd__host_keys %}") "
" (jinja "{{ 'HostCertificate /etc/ssh/{}.pub'.format(cert) }}") "
" (jinja "{% endif %}") "
" (jinja "{% endfor %}") "
" (jinja "{% endif %}") "
")
      (state (jinja "{{ \"present\"
               if (sshd__register_host_certs is defined and
                   \"stdout_lines\" in sshd__register_host_certs)
               else \"ignore\" }}"))
      (copy_id_from "HostKey")
      
      (name "AuthorizedKeysFile")
      (value (list
          
          (name "/etc/ssh/authorized_keys/%u")
          (weight "-100")))
      (state "present")
      
      (name "TrustedUserCAKeys")
      (value (jinja "{{ sshd__trusted_user_ca_keys_file }}"))
      (state (jinja "{{ \"present\"
               if (sshd__trusted_user_ca_keys | d() | length > 0)
               else \"ignore\" }}"))
      (copy_id_from "AuthorizedKeysFile")
      
      (name "Match_group_sftponly")
      (option "Match")
      (comment "Support for strict SFTP UNIX accounts")
      (value "Group sftponly")
      (config "AuthorizedKeysFile /etc/ssh/authorized_keys/%u
ChrootDirectory %h
X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding no
PermitTunnel no
ForceCommand internal-sftp
")
      (state "present")
      (separator "True")
      
      (name "PermitRootLogin")
      (value (jinja "{{ \"prohibit-password\"
               if (ansible_local.root_account.ssh_authorized_keys | d() | bool or
                   ansible_local.system_users.configured | d() | bool)
               else True }}"))
      (state "present")
      
      (name "PasswordAuthentication")
      (value (jinja "{{ False
               if (ansible_local.root_account.ssh_authorized_keys | d() | bool or
                   ansible_local.system_users.configured | d() | bool)
               else True }}"))
      (state "present")
      
      (name "ChallengeResponseAuthentication")
      (value "False")
      (state "present")
      
      (name "KbdInteractiveAuthentication")
      (value "False")
      (state "present")
      
      (name "UseDNS")
      (value "True")
      (state "present")
      
      (name "Ciphers")
      (comment "List of ciphers which are allowed for connections")
      (raw (jinja "{% set sshd__tpl_ciphers_max_version = sshd__ciphers_map.keys() | select('version_compare', sshd__version, '<=') | max %}") "
" (jinja "{% set sshd__tpl_ciphers = sshd__ciphers_map[sshd__tpl_ciphers_max_version] %}") "
" (jinja "{% set sshd__tpl_ciphers = (sshd__tpl_ciphers + sshd__ciphers_additional) | unique %}") "
" (jinja "{% if sshd__tpl_ciphers and sshd__paranoid | bool %}") "
" (jinja "{{ 'Ciphers {}'.format(([sshd__tpl_ciphers | first] + sshd__ciphers_additional) | unique | join(\",\")) }}") "
" (jinja "{% elif sshd__tpl_ciphers %}") "
" (jinja "{{ 'Ciphers {}'.format(sshd__tpl_ciphers | join(\",\")) }}") "
" (jinja "{% endif %}") "
")
      (state "present")
      (copy_id_from "RekeyLimit")
      
      (name "KexAlgorithms")
      (comment "List of allowed key exchange algorithms")
      (raw (jinja "{% set sshd__tpl_kex_algorithms_max_version = sshd__kex_algorithms_map.keys() | select('version_compare', sshd__version, '<=') | max %}") "
" (jinja "{% set sshd__tpl_kex_algorithms = sshd__kex_algorithms_map[sshd__tpl_kex_algorithms_max_version] %}") "
" (jinja "{% set sshd__tpl_kex_algorithms = (sshd__tpl_kex_algorithms + sshd__kex_algorithms_additional) | unique %}") "
" (jinja "{% if sshd__tpl_kex_algorithms and sshd__paranoid | bool %}") "
" (jinja "{{ 'KexAlgorithms {}'.format(([sshd__tpl_kex_algorithms | first] + sshd__kex_algorithms_additional) | unique | join(\",\")) }}") "
" (jinja "{% elif sshd__tpl_kex_algorithms %}") "
" (jinja "{{ 'KexAlgorithms {}'.format(sshd__tpl_kex_algorithms | join(\",\")) }}") "
" (jinja "{% endif %}") "
")
      (state "present")
      (copy_id_from "RekeyLimit")
      
      (name "MACs")
      (comment "List of allowed Message Authentication Code algorithms")
      (raw (jinja "{% set sshd__tpl_macs_max_version = sshd__macs_map.keys() | select('version_compare', sshd__version, '<=') | max %}") "
" (jinja "{% set sshd__tpl_macs = sshd__macs_map[sshd__tpl_macs_max_version] %}") "
" (jinja "{% set sshd__tpl_macs = (sshd__tpl_macs + sshd__macs_additional) | unique %}") "
" (jinja "{% if sshd__tpl_macs and sshd__paranoid | bool %}") "
" (jinja "{{ 'MACs {}'.format(([sshd__tpl_macs | first] + sshd__macs_additional) | unique | join(\",\")) }}") "
" (jinja "{% elif sshd__tpl_macs %}") "
" (jinja "{{ 'MACs {}'.format(sshd__tpl_macs | join(\",\")) }}") "
" (jinja "{% endif %}") "
")
      (state "present")
      (copy_id_from "RekeyLimit")
      
      (name "UsePrivilegeSeparation")
      (comment "Privilege Separation is turned on for security")
      (value "sandbox")
      (state (jinja "{{ \"present\" if (sshd__version is version(\"7.5\", \"<\")) else \"ignore\" }}"))
      (copy_id_from "RekeyLimit")
      
      (name "KeyRegenerationInterval")
      (comment "Lifetime and size of ephemeral version 1 server key")
      (value "3600")
      (state (jinja "{{ \"present\" if (sshd__version is version(\"7.4\", \"<\")) else \"ignore\" }}"))
      (copy_id_from "RekeyLimit")
      
      (name "ServerKeyBits")
      (value "1024")
      (state (jinja "{{ \"present\" if (sshd__version is version(\"7.4\", \"<\")) else \"ignore\" }}"))
      (copy_id_from "RekeyLimit")
      
      (name "AuthorizedKeysCommand")
      (value "/etc/ssh/authorized_keys_lookup")
      (state (jinja "{{ \"present\"
               if (sshd__authorized_keys_lookup | bool and
                   sshd__version is version(\"6.2\", \">=\"))
               else \"ignore\" }}"))
      
      (name "AuthorizedKeysCommandUser")
      (value (jinja "{{ sshd__authorized_keys_lookup_user }}"))
      (state (jinja "{{ \"present\"
               if (sshd__authorized_keys_lookup | bool and
                   sshd__version is version(\"6.2\", \">=\"))
               else \"ignore\" }}"))))
  (sshd__configuration (list))
  (sshd__group_configuration (list))
  (sshd__host_configuration (list))
  (sshd__combined_configuration (jinja "{{ sshd__original_configuration
                                  + sshd__default_configuration
                                  + sshd__configuration
                                  + sshd__group_configuration
                                  + sshd__host_configuration }}"))
  (sshd__known_hosts (list))
  (sshd__group_known_hosts (list))
  (sshd__host_known_hosts (list))
  (sshd__known_hosts_file "/etc/ssh/ssh_known_hosts")
  (sshd__known_hosts_command "ssh-keyscan -H -T 10")
  (sshd__ciphers_map 
    (6.5 (list
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"))
    (6.0 (list
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr")))
  (sshd__ciphers_additional (list))
  (sshd__kex_algorithms_map 
    (6.5 (list
        "curve25519-sha256@libssh.org"
        "ecdh-sha2-nistp521"
        "ecdh-sha2-nistp384"
        "ecdh-sha2-nistp256"
        "diffie-hellman-group-exchange-sha256"))
    (6.0 (list
        "diffie-hellman-group-exchange-sha256")))
  (sshd__kex_algorithms_additional (list))
  (sshd__macs_map 
    (6.5 (list
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        "hmac-sha2-512"
        "hmac-sha2-256"
        "umac-128@openssh.com"))
    (6.0 (list
        "hmac-sha2-512"
        "hmac-sha2-256"
        "hmac-ripemd160")))
  (sshd__macs_additional (list))
  (sshd__moduli_minimum "2048")
  (sshd__paranoid "False")
  (sshd__authorized_keys_lookup (jinja "{{ ansible_local.ldap.posix_enabled | d() | bool }}"))
  (sshd__authorized_keys_lookup_user "sshd")
  (sshd__authorized_keys_lookup_type (list
      "ldap"
      "sss"))
  (sshd__ldap_enabled (jinja "{{ ansible_local.ldap.enabled
                        if (ansible_local | d() and ansible_local.ldap | d() and
                            ansible_local.ldap.enabled is defined)
                        else False }}"))
  (sshd__ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn | d([]) }}"))
  (sshd__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (sshd__ldap_device_object_classes (list
      "ldapPublicKey"))
  (sshd__ldap_device_attributes 
    (sshPublicKey (jinja "{{ sshd__env_register_host_public_keys.stdout_lines }}")))
  (sshd__ldap_self_rdn "uid=" (jinja "{{ sshd__authorized_keys_lookup_user }}"))
  (sshd__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (sshd__ldap_self_attributes 
    (uid (jinja "{{ sshd__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ sshd__ldap_bindpw }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"sshd\" service to access the LDAP directory"))
  (sshd__ldap_binddn (jinja "{{ ([sshd__ldap_self_rdn] + sshd__ldap_device_dn) | join(\",\") }}"))
  (sshd__ldap_bindpw (jinja "{{ (lookup(\"password\", secret + \"/ldap/credentials/\"
                               + sshd__ldap_binddn | to_uuid + \".password length=32\"))
                       if sshd__ldap_enabled | bool
                       else \"\" }}"))
  (sshd__ldap_filter (jinja "{{ sshd__ldap_filter_map[\"service+host\"] }}"))
  (sshd__ldap_posix_urns (jinja "{{ ansible_local.ldap.urn_patterns | d([])
                           | map(\"regex_replace\", \"^(.*)$\", \"(host=posix:urn:\\1)\")
                           | list }}"))
  (sshd__ldap_filter_map 
    (service "(& (objectClass=posixAccount) (uid=$username) (| (authorizedService=all) (authorizedService=$service) (authorizedService=shell) ) )")
    (host "(& (objectClass=posixAccount) (uid=$username) (| (host=posix:all) (host=posix:$fqdn) (host=posix:\\2a.$domain) " (jinja "{{ sshd__ldap_posix_urns | join(\" \") }}") " ) )")
    (service+host "(& (objectClass=posixAccount) (uid=$username) (| (authorizedService=all) (authorizedService=$service) (authorizedService=shell) ) (| (host=posix:all) (host=posix:$fqdn) (host=posix:\\2a.$domain) " (jinja "{{ sshd__ldap_posix_urns | join(\" \") }}") " ) )"))
  (sshd__pam_deploy_state "present")
  (sshd__pam_access_file (jinja "{{ \"/etc/security/access-sshd.conf\"
                           if (\"sshd\" in ansible_local.pam_access.rules | d([]))
                           else \"/etc/security/access.conf\" }}"))
  (sshd__ferm__dependent_rules (list
      
      (type "accept")
      (dport (jinja "{{ sshd__ferm_ports }}"))
      (interface (jinja "{{ sshd__ferm_interface }}"))
      (weight "0")
      (weight_class "sshd-chain")
      (name "sshd_jump-filter-ssh")
      (target (jinja "{{ sshd__ferm_limit_chain }}"))
      (rule_state (jinja "{{ \"present\" if sshd__ferm_limit | bool else \"absent\" }}"))
      (comment "Create a separate \"iptables\" chain for SSH rules")
      
      (chain (jinja "{{ sshd__ferm_limit_chain if (sshd__ferm_limit | bool) else \"INPUT\" }}"))
      (type "accept")
      (dport (jinja "{{ sshd__ferm_ports }}"))
      (saddr (jinja "{{ sshd__whitelist + sshd__group_whitelist + sshd__host_whitelist }}"))
      (interface (jinja "{{ [] if (sshd__ferm_limit | bool) else sshd__ferm_interface }}"))
      (weight "1")
      (weight_class "sshd-chain")
      (name "sshd_whitelist")
      (subchain "False")
      (accept_any "False")
      (comment "Accept any hosts in the whitelist unconditionally")
      
      (chain (jinja "{{ sshd__ferm_limit_chain if sshd__ferm_limit | bool else \"INPUT\" }}"))
      (type "accept")
      (dport (jinja "{{ sshd__ferm_ports }}"))
      (saddr (jinja "{{ sshd__allow + sshd__group_allow + sshd__host_allow }}"))
      (interface (jinja "{{ [] if (sshd__ferm_limit | bool) else sshd__ferm_interface }}"))
      (weight "2")
      (weight_class "sshd-chain")
      (name "sshd_allow")
      (subchain "False")
      (accept_any (jinja "{{ False if sshd__ferm_limit | bool else True }}"))
      (comment "Accept any hosts in the allow list. If there are any hosts specified,
block connections from other hosts using TCP Wrappers.
")
      
      (chain (jinja "{{ sshd__ferm_limit_chain }}"))
      (type "recent")
      (weight "3")
      (weight_class "sshd-chain")
      (name "sshd_block-ssh")
      (dport (jinja "{{ sshd__ferm_ports }}"))
      (state (list
          "NEW"))
      (subchain "False")
      (recent_name "ssh-new")
      (recent_update "True")
      (recent_seconds (jinja "{{ sshd__ferm_limit_seconds }}"))
      (recent_hitcount (jinja "{{ sshd__ferm_limit_hits }}"))
      (recent_target "REJECT")
      (rule_state (jinja "{{ \"present\" if sshd__ferm_limit | bool else \"absent\" }}"))
      (comment "Block new SSH connections that have been marked as recent if they make
too many new connection attempts.
")
      
      (chain (jinja "{{ sshd__ferm_limit_chain }}"))
      (type "recent")
      (weight "4")
      (weight_class "sshd-chain")
      (name "sshd_mark-ssh")
      (dport (jinja "{{ sshd__ferm_ports }}"))
      (state (list
          "NEW"))
      (subchain "False")
      (recent_set_name "ssh-new")
      (recent_log "False")
      (rule_state (jinja "{{ \"present\" if sshd__ferm_limit | bool else \"absent\" }}"))
      (comment "Mark new connections to the SSH service for recent tracking")
      
      (chain (jinja "{{ sshd__ferm_limit_chain }}"))
      (type "accept")
      (weight "5")
      (weight_class "sshd-chain")
      (role "sshd")
      (role_weight "60")
      (name "sshd_accept-ssh")
      (dport (jinja "{{ sshd__ferm_ports }}"))
      (rule_state (jinja "{{ \"present\" if sshd__ferm_limit | bool else \"absent\" }}"))
      (comment "Accept connections to the SSH service")))
  (sshd__tcpwrappers__dependent_allow (list
      
      (daemon "sshd")
      (client (jinja "{{ sshd__whitelist + sshd__group_whitelist + sshd__host_whitelist }}"))
      (accept_any (jinja "{{ False if (sshd__allow + sshd__group_allow + sshd__host_allow) else True }}"))
      (weight "25")
      (filename "sshd_dependent_whitelist")
      (comment "Whitelist of hosts allowed to connect to ssh")
      
      (daemon "sshd")
      (client (jinja "{{ sshd__allow + sshd__group_allow + sshd__host_allow }}"))
      (default (jinja "{{ sshd__tcpwrappers_default }}"))
      (accept_any (jinja "{{ True if (sshd__whitelist + sshd__group_whitelist + sshd__host_whitelist) else False }}"))
      (weight "30")
      (filename "sshd_dependent_allow")
      (comment "List of hosts allowed to connect to ssh")))
  (sshd__ldap__dependent_tasks (list
      
      (name "Add missing LDAP object classes to " (jinja "{{ sshd__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ sshd__ldap_device_dn }}"))
      (attributes 
        (objectClass (jinja "{{ sshd__ldap_device_object_classes }}")))
      (state (jinja "{{ \"present\"
               if ((ansible_local.ldap.posix_enabled | d()) | bool and
                   sshd__ldap_device_dn | d())
               else \"ignore\" }}"))
      
      (name "Update SSH host public keys in " (jinja "{{ sshd__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ sshd__ldap_device_dn }}"))
      (attributes (jinja "{{ sshd__ldap_device_attributes }}"))
      (state (jinja "{{ \"exact\"
               if ((ansible_local.ldap.posix_enabled | d()) | bool and
                   sshd__ldap_device_dn | d())
               else \"ignore\" }}"))
      
      (name "Create sshd account for " (jinja "{{ sshd__ldap_device_dn | join(\",\") }}"))
      (dn (jinja "{{ sshd__ldap_binddn }}"))
      (objectClass (jinja "{{ sshd__ldap_self_object_classes }}"))
      (attributes (jinja "{{ sshd__ldap_self_attributes }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (state (jinja "{{ \"present\"
               if (sshd__authorized_keys_lookup | bool and
                   (\"ldap\" in sshd__authorized_keys_lookup_type))
               else \"ignore\" }}"))))
  (sshd__pam_access__dependent_rules (list
      
      (name "sshd")
      (options (list
          
          (name "allow-root-ansible-controllers")
          (comment "Grant access via SSH to root account from the Ansible Controller hosts")
          (permission "allow")
          (users "root")
          (origins (jinja "{{ ansible_local.core.ansible_controllers | d([]) }}"))
          
          (name "allow-root")
          (comment "Grant access via SSH to root account on the same DNS domain")
          (permission "allow")
          (users "root")
          (origins "." (jinja "{{ ansible_domain }}"))
          
          (name "deny-root")
          (comment "Deny access to root account via SSH from anywhere else")
          (permission "deny")
          (users "root")
          (origins "ALL")
          
          (name "allow-system-groups")
          (comment "Grant access via SSH to members of UNIX groups defined on this host
")
          (permission "allow")
          (groups (jinja "{{ ansible_local.system_groups.access.sshd
                    | d([\"admins\", \"sshusers\", \"sftponly\"]) }}"))
          (origins "ALL")
          
          (name "allow-ldap-groups")
          (comment "Grant access via SSH to members of UNIX groups defined in LDAP
")
          (permission "allow")
          (groups (list
              "admins"
              "sshusers"
              "sftponly"))
          (origins "ALL")
          (state (jinja "{{ \"present\"
                   if (ansible_local.ldap.posix_enabled | d() | bool)
                   else \"absent\" }}"))
          
          (name "allow-domain")
          (comment "Grant access via SSH to users on the same DNS domain. The SSH server
needs to have UseDNS option enabled for this rule to work correctly.
")
          (permission "allow")
          (users "ALL")
          (origins "." (jinja "{{ ansible_domain }}"))
          
          (name "deny-all")
          (comment "Deny access via SSH by anyone from anywhere")
          (permission "deny")
          (users "ALL")
          (origins "ALL")
          (weight "99999")))))
  (sshd__sudo__dependent_sudoers (list
      
      (name "sshd")
      (options (list
          
          (name "env_keep_ssh")
          (comment "Allow molly-guard to detect that we connected via ssh even if
combined with sudo and tmux.
https://superuser.com/questions/666931/getting-molly-guard-to-work-with-sudo
It is not perfect, but works in most cases.
A case where it does not work is when `sudo tmux` is started via
local tty and then attached to it via ssh.
Or `sudo tmux` is executed via ssh and then attached locally.
But when a new shell is created in tmux, the environment variables in
that new shell are correct.")
          (value "Defaults env_keep += SSH_CONNECTION
"))))))
