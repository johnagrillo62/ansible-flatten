(playbook "debops/ansible/roles/slapd/defaults/main.yml"
  (slapd__rfc2307bis_enabled (jinja "{{ ansible_local.slapd.rfc2307bis | d(True) | bool }}"))
  (slapd__debops_schema_path "/etc/ldap/schema/debops")
  (slapd__default_schemas (list
      (jinja "{{ slapd__debops_schema_path + \"/debops.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/posixgroupid.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/nextuidgid.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/orgstructure.schema\" }}")
      "/etc/ldap/schema/ppolicy.schema"
      "/etc/ldap/schema/fusiondirectory/ldapns.schema"
      (jinja "{{ slapd__debops_schema_path + \"/groupofentries.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/openssh-lpk.schema\" }}")
      "/etc/ldap/schema/fusiondirectory/sudo.schema"
      (jinja "{{ slapd__debops_schema_path + \"/eduperson.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/schac.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/nextcloud.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/mailservice.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/dyngroup.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/freeradius.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/freeradius-client.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/freeradius-profile.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/freeradius-radacct.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/freeradius-dhcpv4.schema\" }}")
      (jinja "{{ slapd__debops_schema_path + \"/freeradius-dhcpv6.schema\" }}")))
  (slapd__schemas (list))
  (slapd__group_schemas (list))
  (slapd__host_schemas (list))
  (slapd__combined_schemas (jinja "{{ slapd__default_schemas
                             + slapd__schemas
                             + slapd__group_schemas
                             + slapd__host_schemas }}"))
  (slapd__base_packages (list
      "slapd"
      "ldap-utils"
      "ssl-cert"
      "libldap-common"))
  (slapd__rfc2307bis_packages (list
      "fusiondirectory-schema"))
  (slapd__schema_packages (list
      "fusiondirectory-plugin-sudo-schema"))
  (slapd__packages (list))
  (slapd__user "openldap")
  (slapd__group "openldap")
  (slapd__additional_groups (list
      "ssl-cert"))
  (slapd__additional_database_dirs (list))
  (slapd__log_dir "/var/log/slapd")
  (slapd__domain (jinja "{{ ansible_domain }}"))
  (slapd__base_dn (jinja "{{ slapd__domain.split(\".\")
                    | map(\"regex_replace\", \"^(.*)$\", \"dc=\\1\")
                    | list }}"))
  (slapd__basedn (jinja "{{ slapd__base_dn | join(\",\") }}"))
  (slapd__superuser_config_password (jinja "{{ \"{CRYPT}\" + lookup(\"password\", secret
                                                         + \"/slapd/credentials/\"
                                                         + slapd__config_rootdn | to_uuid + \".password\"
                                                         + \" encrypt=sha512_crypt length=32\") }}"))
  (slapd__config_rootdn "cn=admin,cn=config")
  (slapd__config_rootpw (jinja "{{ lookup(\"file\", secret + \"/slapd/credentials/\"
                                         + slapd__config_rootdn | to_uuid
                                         + \".password\").split()[0] }}"))
  (slapd__superuser_data_password (jinja "{{ \"{CRYPT}\" + lookup(\"password\", secret
                                                       + \"/slapd/credentials/\"
                                                       + slapd__data_rootdn | to_uuid + \".password\"
                                                       + \" encrypt=sha512_crypt length=32\") }}"))
  (slapd__data_rootdn (jinja "{{ ([\"cn=admin\"] + slapd__base_dn) | join(\",\") }}"))
  (slapd__data_rootpw (jinja "{{ lookup(\"file\", secret + \"/slapd/credentials/\"
                                       + slapd__data_rootdn | to_uuid
                                       + \".password\").split()[0] }}"))
  (slapd__uid_gid_min "2000000000")
  (slapd__groupid_min (jinja "{{ slapd__uid_gid_min }}"))
  (slapd__groupid_max (jinja "{{ slapd__uid_gid_min | int + 1999999 }}"))
  (slapd__uid_gid_max (jinja "{{ slapd__uid_gid_min | int + 99999999 }}"))
  (slapd__saslauthd_enabled "True")
  (slapd__data_max_size (jinja "{{ (1024 * 1024 * 1024) * 10 }}"))
  (slapd__pki (jinja "{{ ansible_local.pki.enabled | d(False) | bool }}"))
  (slapd__pki_path (jinja "{{ ansible_local.pki.base_path | d(\"/etc/pki/realms\") }}"))
  (slapd__pki_realm (jinja "{{ slapd__domain
                      if (slapd__domain in ansible_local.pki.known_realms | d([]))
                      else ansible_local.pki.realm | d(\"domain\") }}"))
  (slapd__pki_ca "CA.crt")
  (slapd__pki_crt "default.crt")
  (slapd__pki_key "default.key")
  (slapd__dhparam_set "default")
  (slapd__dhparam_file (jinja "{{ ansible_local.dhparam[slapd__dhparam_set] | d(\"\") }}"))
  (slapd__tls_ca_certificate (jinja "{{ slapd__pki_path + \"/\" + slapd__pki_realm + \"/\" + slapd__pki_ca }}"))
  (slapd__tls_certificate (jinja "{{ slapd__pki_path + \"/\" + slapd__pki_realm + \"/\" + slapd__pki_crt }}"))
  (slapd__tls_private_key (jinja "{{ slapd__pki_path + \"/\" + slapd__pki_realm + \"/\" + slapd__pki_key }}"))
  (slapd__tls_cipher_suite "SECURE256:PFS:-VERS-SSL3.0:-VERS-TLS-ALL:+VERS-TLS1.2:-SHA1:-ARCFOUR-128")
  (slapd__default_tasks (list
      
      (name "Define the maximum size of the main database")
      (dn (list
          "olcDatabase={1}mdb"
          "cn=config"))
      (attributes 
        (olcDbMaxSize (jinja "{{ slapd__data_max_size }}")))
      (state "exact")
      
      (name "Load dynamic OpenLDAP modules")
      (dn "cn=module{0},cn=config")
      (attributes 
        (olcModuleLoad (list
            "{0}back_mdb"
            "{1}syncprov"
            "{2}ppolicy"
            "{3}unique"
            "{4}memberof"
            "{5}refint"
            "{6}auditlog"
            "{7}constraint"
            "{8}back_monitor"
            "{9}lastbind"
            "{10}autogroup")))
      (ordered "True")
      
      (name "Enable Sync Provider overlay in the cn=config database")
      (dn "olcOverlay={0}syncprov,olcDatabase={0}config,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcSyncProvConfig"))
      (attributes 
        (olcOverlay "{0}syncprov"))
      
      (name "Enable Sync Provider overlay in the main database")
      (dn "olcOverlay={0}syncprov,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcSyncProvConfig"))
      (attributes 
        (olcOverlay "{0}syncprov"))
      
      (name "Enable Password Policy overlay in the main database")
      (dn "olcOverlay={1}ppolicy,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcPPolicyConfig"))
      (attributes 
        (olcOverlay "{1}ppolicy"))
      
      (name "Enable Unique overlay in the main database")
      (dn "olcOverlay={2}unique,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcUniqueConfig"))
      (attributes 
        (olcOverlay "{2}unique"))
      
      (name "Enable memberOf overlay in the main database for groupOfNames")
      (dn "olcOverlay={3}memberof,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcMemberOf"))
      (attributes 
        (olcOverlay "{3}memberof"))
      
      (name "Enable memberOf overlay in the main database for groupOfEntries")
      (dn "olcOverlay={4}memberof,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcMemberOf"))
      (attributes 
        (olcOverlay "{4}memberof"))
      
      (name "Enable memberOf overlay in the main database for AutoGroups")
      (dn "olcOverlay={5}memberof,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcMemberOf"))
      (attributes 
        (olcOverlay "{5}memberof"))
      
      (name "Enable memberOf overlay in the main database for Roles")
      (dn "olcOverlay={6}memberof,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcMemberOf"))
      (attributes 
        (olcOverlay "{6}memberof"))
      
      (name "Enable Referential Integrity overlay in the main database")
      (dn "olcOverlay={7}refint,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcRefintConfig"))
      (attributes 
        (olcOverlay "{7}refint"))
      
      (name "Enable Audit Logging overlay in the main database")
      (dn "olcOverlay={8}auditlog,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcAuditLogConfig"))
      (attributes 
        (olcOverlay "{8}auditlog"))
      
      (name "Enable Constraint overlay in the main database")
      (dn "olcOverlay={9}constraint,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcConstraintConfig"))
      (attributes 
        (olcOverlay "{9}constraint"))
      
      (name "Enable AutoGroup overlay in the main database")
      (dn "olcOverlay={10}autogroup,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcAutomaticGroups"))
      (attributes 
        (olcOverlay "{10}autogroup"))
      
      (name "Enable LastBind overlay in the main database")
      (dn "olcOverlay={11}lastbind,olcDatabase={1}mdb,cn=config")
      (objectClass (list
          "olcOverlayConfig"
          "olcLastBindConfig"))
      (attributes 
        (olcOverlay "{11}lastbind"))
      
      (name "Configure Password Policy overlay in the main database")
      (dn "olcOverlay={1}ppolicy,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcPPolicyDefault "cn=Default Password Policy,ou=Password Policies," (jinja "{{ slapd__basedn }}"))
        (olcPPolicyHashCleartext "TRUE")
        (olcPPolicyUseLockout "FALSE")
        (olcPPolicyForwardUpdates "FALSE"))
      (state "exact")
      
      (name "Configure Unique overlay in the main database")
      (dn "olcOverlay={2}unique,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcUniqueURI (list
            "ldap:///" (jinja "{{ slapd__basedn }}") "?uidNumber?sub"
            "ldap:///" (jinja "{{ slapd__basedn }}") "?gidNumber?sub"
            "ldap:///" (jinja "{{ slapd__basedn }}") "?mail?sub"
            "ldap:///" (jinja "{{ slapd__basedn }}") "?mailAddress,mailAlternateAddress?sub"
            "ldap:///" (jinja "{{ slapd__basedn }}") "?mailPrivateAddress?sub"
            "ldap:///ou=People," (jinja "{{ slapd__basedn }}") "?employeeNumber?sub"
            "ldap:///ou=People," (jinja "{{ slapd__basedn }}") "?uid?sub"
            "ldap:///ou=People," (jinja "{{ slapd__basedn }}") "?gid?sub")))
      (state "exact")
      
      (name "Configure memberOf overlay in the main database for groupOfNames")
      (dn "olcOverlay={3}memberof,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcMemberOfDangling "ignore")
        (olcMemberOfRefInt "TRUE")
        (olcMemberOfGroupOC "groupOfNames")
        (olcMemberOfMemberAD "member")
        (olcMemberOfMemberOfAD "memberOf"))
      (state "exact")
      
      (name "Configure memberOf overlay in the main database for groupOfEntries")
      (dn "olcOverlay={4}memberof,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcMemberOfDangling "ignore")
        (olcMemberOfRefInt "TRUE")
        (olcMemberOfGroupOC "groupOfEntries")
        (olcMemberOfMemberAD "member")
        (olcMemberOfMemberOfAD "memberOf"))
      (state "exact")
      
      (name "Configure memberOf overlay in the main database for AutoGroups")
      (dn "olcOverlay={5}memberof,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcMemberOfDangling "ignore")
        (olcMemberOfRefInt "TRUE")
        (olcMemberOfGroupOC "groupOfURLs")
        (olcMemberOfMemberAD "member")
        (olcMemberOfMemberOfAD "memberOf"))
      (state "exact")
      
      (name "Configure memberOf overlay in the main database for Roles")
      (dn "olcOverlay={6}memberof,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcMemberOfDangling "ignore")
        (olcMemberOfRefInt "TRUE")
        (olcMemberOfGroupOC "organizationalRole")
        (olcMemberOfMemberAD "roleOccupant")
        (olcMemberOfMemberOfAD "memberOf"))
      (state "exact")
      
      (name "Configure Referential Integrity overlay in the main database")
      (dn "olcOverlay={7}refint,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcRefintAttribute (list
            "member"
            "memberOf"
            "uniqueMember"
            "manager"
            "owner"
            "roleOccupant"
            "seeAlso"
            "secretary"
            "documentAuthor")))
      (state "exact")
      
      (name "Configure Audit Logging overlay in the main database")
      (dn "olcOverlay={8}auditlog,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcAuditlogFile (jinja "{{ slapd__log_dir + \"/slapd-auditlog-main.ldif\" }}")))
      (state "exact")
      
      (name "Configure Constraint overlay in the main database")
      (dn "olcOverlay={9}constraint,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcConstraintAttribute (list
            "jpegPhoto size 524288"
            "userPassword count 5"
            "employeeNumber regex ^[[:digit:]]+$"
            "uidNumber regex ^[[:digit:]]+$"
            "gidNumber regex ^[[:digit:]]+$"
            "macAddress regex ^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
            "mailAddress set \"this/mailAddress & this/mail\""
            "mailPrivateAddress set \"this/mailPrivateAddress & this/mail\""
            "mailAlternateAddress set \"this/mailAlternateAddress & this/mail\"")))
      (state "exact")
      
      (name "Configure AutoGroup overlay in the main database")
      (dn "olcOverlay={10}autogroup,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcAGattrSet (list
            "{0}groupOfURLs memberURL member"))
        (olcAGmemberOfAd "memberOf"))
      (state "exact")
      
      (name "Configure LastBind overlay in the main database")
      (dn "olcOverlay={11}lastbind,olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcLastBindPrecision (jinja "{{ (60 * 60 * 24) }}")))
      (state "exact")
      
      (name "Configure the OpenLDAP server log level")
      (dn "cn=config")
      (attributes 
        (olcLogLevel "none"))
      (state "exact")
      
      (name "Define the default password hashing method")
      (dn (list
          "olcDatabase={-1}frontend"
          "cn=config"))
      (attributes 
        (olcPasswordHash "{CRYPT}"))
      (state "exact")
      
      (name "Configure password salt format used by the crypt(3) hash function")
      (dn "cn=config")
      (attributes 
        (olcPasswordCryptSaltFormat "$6$rounds=100001$%.16s"))
      (state "exact")
      
      (name "Set the cn=config database root credentials")
      (dn (list
          "olcDatabase={0}config"
          "cn=config"))
      (attributes 
        (olcRootDN (jinja "{{ slapd__config_rootdn }}"))
        (olcRootPW (jinja "{{ slapd__superuser_config_password }}")))
      (state "exact")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      
      (name "Set the cn=config database access control list")
      (dn (list
          "olcDatabase={0}config"
          "cn=config"))
      (attributes 
        (olcAccess (list
            "{0}to dn.subtree=\"cn=config\"
   by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage
   by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" manage
   by * break")))
      (state "exact")
      
      (name "Set the main database root credentials")
      (dn (list
          "olcDatabase={1}mdb"
          "cn=config"))
      (attributes 
        (olcRootDN (jinja "{{ slapd__data_rootdn }}"))
        (olcRootPW (jinja "{{ slapd__superuser_data_password }}")))
      (state "exact")
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      
      (name "Configure idle and write timeouts")
      (dn "cn=config")
      (attributes 
        (olcIdleTimeout "900")
        (olcWriteTimeout "900"))
      (state "exact")
      
      (name "Configure TLS certificates")
      (dn "cn=config")
      (attributes 
        (olcTLSCACertificateFile (jinja "{{ slapd__tls_ca_certificate }}"))
        (olcTLSCertificateFile (jinja "{{ slapd__tls_certificate }}"))
        (olcTLSCertificateKeyFile (jinja "{{ slapd__tls_private_key }}")))
      (state (jinja "{{ \"exact\" if slapd__pki | bool else \"init\" }}"))
      
      (name "Configure Diffie-Hellman parameters")
      (dn "cn=config")
      (attributes 
        (olcTLSDHParamFile (jinja "{{ slapd__dhparam_file }}")))
      (state (jinja "{{ \"exact\" if (slapd__pki | bool and slapd__dhparam_file | d()) else \"init\" }}"))
      
      (name "Configure TLS cipher suites")
      (dn "cn=config")
      (attributes 
        (olcTLSCipherSuite (jinja "{{ slapd__tls_cipher_suite }}")))
      (state (jinja "{{ \"exact\" if slapd__pki | bool else \"init\" }}"))
      
      (name "Set default Security Strength Factors enforced by the server")
      (dn "cn=config")
      (attributes 
        (olcLocalSSF "128")
        (olcSecurity "ssf=128 update_ssf=128 simple_bind=128"))
      (state (jinja "{{ \"exact\" if slapd__pki | bool else \"init\" }}"))
      
      (name "Configure supported SASL authentication methods")
      (dn "cn=config")
      (attributes 
        (olcSaslSecProps "noanonymous,minssf=" (jinja "{{ \"128\" if slapd__pki | bool else \"0\" }}")))
      (state "exact")
      
      (name "Define SASL regex matching rules")
      (dn "cn=config")
      (attributes 
        (olcAuthzRegexp (list
            "{0}uid=([^,]*),cn=[^,]*,cn=auth uid=$1,ou=People," (jinja "{{ slapd__basedn }}")
            "{1}uid=([^,]*),cn=([^,]*),cn=[^,]*,cn=auth ldap:///ou=Hosts," (jinja "{{ slapd__basedn }}") "??sub?(&(objectClass=account)(uid=$1)(host=$2))")))
      (state "exact")
      
      (name "Define indexes present in the main database")
      (dn (list
          "olcDatabase={1}mdb"
          "cn=config"))
      (attributes 
        (olcDbIndex (list
            "dc eq"
            "cn,uid eq"
            "member,memberUid eq"
            "roleOccupant eq"
            "memberOf eq"
            "objectClass eq"
            "sn eq,pres"
            "gn eq,pres"
            "gecos eq,pres"
            "homeDirectory,loginShell eq"
            "employeeNumber eq"
            "uidNumber,gidNumber eq"
            "entryCSN,entryUUID eq"
            "sudoHost,sudoUser eq,sub"
            "modifyTimestamp eq"
            "authorizedService eq"
            "host eq,sub"
            "gid eq"
            "mail eq,sub"
            "mailAddress eq,sub"
            "mailPrivateAddress eq,sub"
            "mailAlternateAddress eq,sub")))
      
      (name "Enable the monitor database")
      (dn "olcDatabase={2}monitor,cn=config")
      (objectClass (list
          "olcDatabaseConfig"
          "olcMonitorConfig"))
      (attributes 
        (olcDatabase "{2}monitor")
        (olcAccess (list
            "{0}to dn.subtree=\"cn=Monitor\"
   by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth read
   by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
   by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Monitor,       ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
   by group/groupOfNames/member.exact=\"cn=LDAP Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" read
   by group/groupOfNames/member.exact=\"cn=LDAP Monitors,       ou=System Groups," (jinja "{{ slapd__basedn }}") "\" read
   by * none")))
      (state "present")))
  (slapd__acl_tasks (list
      
      (name "Configure Access Control List")
      (dn "olcDatabase={1}mdb,cn=config")
      (ordered "True")
      (attributes 
        (olcAccess (list
            "to dn.subtree=\"" (jinja "{{ slapd__basedn }}") "\"
by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" manage
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Replicator,    ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
by group/groupOfNames/member.exact=\"cn=LDAP Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" manage
by group/groupOfNames/member.exact=\"cn=LDAP Replicators,    ou=System Groups," (jinja "{{ slapd__basedn }}") "\" read
by * break"
            "to dn.subtree=\"" (jinja "{{ slapd__basedn }}") "\" filter=\"(memberOf=cn=Hidden Objects, ou=Groups," (jinja "{{ slapd__basedn }}") ")\"
   attrs=\"children,entry\"
by self break
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Administrator,    ou=Roles," (jinja "{{ slapd__basedn }}") "\" break
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Editor,           ou=Roles," (jinja "{{ slapd__basedn }}") "\" break
by group/organizationalRole/roleOccupant.exact=\"cn=Hidden Object Viewer,  ou=Roles," (jinja "{{ slapd__basedn }}") "\" break
by group/groupOfNames/member.exact=\"cn=LDAP Administrators,    ou=System Groups," (jinja "{{ slapd__basedn }}") "\" break
by group/groupOfNames/member.exact=\"cn=LDAP Editors,           ou=System Groups," (jinja "{{ slapd__basedn }}") "\" break
by * none"
            "to filter=\"(| (objectClass=posixAccount) (objectClass=posixGroup) (objectClass=posixGroupId) (objectClass=uidNext) (objectClass=gidNext) )\"
   attrs=\"uid,uidNumber,gid,gidNumber,homeDirectory\"
by group/groupOfNames/member=\"cn=UNIX Administrators, ou=Groups," (jinja "{{ slapd__basedn }}") "\"        write
by group/groupOfNames/member=\"cn=UNIX Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" write
by users read"
            "to dn.subtree=\"ou=SUDOers," (jinja "{{ slapd__basedn }}") "\"
by group/groupOfNames/member=\"cn=UNIX Administrators, ou=Groups," (jinja "{{ slapd__basedn }}") "\"        write
by group/groupOfNames/member=\"cn=UNIX Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" write
by users read"
            "to dn.subtree=\"ou=People," (jinja "{{ slapd__basedn }}") "\"
   attrs=\"shadowLastChange\"
by self write
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Editor,           ou=Roles," (jinja "{{ slapd__basedn }}") "\" write
by group/organizationalRole/roleOccupant.exact=\"cn=Account Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" write
by group/organizationalRole/roleOccupant.exact=\"cn=Password Reset Agent,  ou=Roles," (jinja "{{ slapd__basedn }}") "\" =w
by group/groupOfNames/member.exact=\"cn=LDAP Editors,           ou=System Groups," (jinja "{{ slapd__basedn }}") "\" write
by group/groupOfNames/member.exact=\"cn=Account Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" write
by group/groupOfNames/member.exact=\"cn=Password Reset Agents,  ou=System Groups," (jinja "{{ slapd__basedn }}") "\" =w
by users read"
            "to dn.subtree=\"ou=People," (jinja "{{ slapd__basedn }}") "\"
   attrs=\"userPassword\"
by self =wx
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Editor,           ou=Roles," (jinja "{{ slapd__basedn }}") "\" =w
by group/organizationalRole/roleOccupant.exact=\"cn=Account Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" =w
by group/organizationalRole/roleOccupant.exact=\"cn=Password Reset Agent,  ou=Roles," (jinja "{{ slapd__basedn }}") "\" =w
by group/groupOfNames/member.exact=\"cn=LDAP Editors,           ou=System Groups," (jinja "{{ slapd__basedn }}") "\" =w
by group/groupOfNames/member.exact=\"cn=Account Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" =w
by group/groupOfNames/member.exact=\"cn=Password Reset Agents,  ou=System Groups," (jinja "{{ slapd__basedn }}") "\" =w
by anonymous auth
by * none"
            "to attrs=\"userPassword\"
by self      =wx
by anonymous auth
by *         none"
            "to dn.regex=\"^cn=(LDAP Administrator|LDAP Replicator), ou=Roles," (jinja "{{ slapd__basedn }}") "$\"
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Editor,           ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
by group/organizationalRole/roleOccupant.exact=\"cn=Account Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
by group/groupOfNames/member.exact=\"cn=LDAP Editors,           ou=System Groups," (jinja "{{ slapd__basedn }}") "\" read
by group/groupOfNames/member.exact=\"cn=Account Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" read
by * break"
            "to dn.subtree=\"cn=UNIX Administrators, ou=Groups," (jinja "{{ slapd__basedn }}") "\"
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Editor,           ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
by group/organizationalRole/roleOccupant.exact=\"cn=Account Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
by group/groupOfNames/member.exact=\"cn=LDAP Editors,           ou=System Groups," (jinja "{{ slapd__basedn }}") "\" read
by group/groupOfNames/member.exact=\"cn=Account Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" read
by * break"
            "to dn.subtree=\"ou=System Groups," (jinja "{{ slapd__basedn }}") "\"
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Editor, ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
by group/groupOfNames/member.exact=\"cn=LDAP Editors, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" read
by * break"
            "to dn.subtree=\"" (jinja "{{ slapd__basedn }}") "\"
by group/organizationalRole/roleOccupant.exact=\"cn=LDAP Editor, ou=Roles," (jinja "{{ slapd__basedn }}") "\" write
by group/groupOfNames/member.exact=\"cn=LDAP Editors, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" write
by * break"
            "to dn.regex=\"^cn=[^,]+,ou=(System Groups|Groups)," (jinja "{{ slapd__basedn }}") "$\"
   attrs=\"member\"
by dnattr=\"owner\" write
by * break"
            "to dn.regex=\"^([^,]+,)?ou=(People|Groups|Machines)," (jinja "{{ slapd__basedn }}") "$\"
   attrs=\"children,entry\"
by group/organizationalRole/roleOccupant.exact=\"cn=Account Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" write
by group/groupOfNames/member.exact=\"cn=Account Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" write
by * break"
            "to dn.regex=\"^[^,]+,ou=(People|Groups|Machines)," (jinja "{{ slapd__basedn }}") "$\"
by group/organizationalRole/roleOccupant.exact=\"cn=Account Administrator, ou=Roles," (jinja "{{ slapd__basedn }}") "\" write
by group/groupOfNames/member.exact=\"cn=Account Administrators, ou=System Groups," (jinja "{{ slapd__basedn }}") "\" write
by * break"
            "to attrs=\"carLicense,homePhone,homePostalAddress\"
by self write
by * none"
            "to attrs=\"mobile\"
by self write
by group/organizationalRole/roleOccupant.exact=\"cn=SMS Gateway, ou=Roles," (jinja "{{ slapd__basedn }}") "\" read
by * none"
            "to *
by users read
by * none")))
      (state "exact")))
  (slapd__cluster_tasks (list))
  (slapd__structure_tasks (list
      
      (name "Remove the default cn=admin object")
      (dn (jinja "{{ [\"cn=admin\"] + slapd__base_dn }}"))
      (state "absent")
      (entry_state "absent")
      
      (name "Create the ou=Groups object")
      (dn (jinja "{{ [\"ou=Groups\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      
      (name "Create the ou=Machines object")
      (dn (jinja "{{ [\"ou=Machines\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      
      (name "Create the ou=Hosts object")
      (dn (jinja "{{ [\"ou=Hosts\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      
      (name "Create the ou=People object")
      (dn (jinja "{{ [\"ou=People\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      
      (name "Create the ou=Roles object")
      (dn (jinja "{{ [\"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      
      (name "Create the ou=Services object")
      (dn (jinja "{{ [\"ou=Services\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      
      (name "Create the ou=Password Policies object")
      (dn (jinja "{{ [\"ou=Password Policies\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      
      (name "Create the ou=System object")
      (dn (jinja "{{ [\"ou=System\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      
      (name "Create the cn=Default Password Policy object")
      (dn (jinja "{{ [\"cn=Default Password Policy\", \"ou=Password Policies\"] + slapd__base_dn }}"))
      (objectClass (list
          "namedObject"
          "pwdPolicy"))
      (attributes 
        (cn "Default Password Policy")
        (pwdAttribute "userPassword")
        (pwdMaxAge "0")
        (pwdInHistory "5")
        (pwdCheckQuality "1")
        (pwdMinLength "10")
        (pwdExpireWarning "1209600")
        (pwdGraceAuthNLimit "5")
        (pwdLockout "FALSE")
        (pwdLockoutDuration "300")
        (pwdMaxFailure "5")
        (pwdFailureCountInterval "0")
        (pwdMustChange "FALSE")
        (pwdAllowUserChange "TRUE")
        (pwdSafeModify "FALSE"))
      
      (name "Create cn=LDAP Administrator role")
      (dn (jinja "{{ [\"cn=LDAP Administrator\", \"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalRole")
      (attributes 
        (cn "LDAP Administrator")
        (description "People responsible for LDAP infrastructure"))
      
      (name "Create cn=LDAP Replicator role")
      (dn (jinja "{{ [\"cn=LDAP Replicator\", \"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalRole")
      (attributes 
        (cn "LDAP Replicator")
        (description "Service accounts used for LDAP replication"))
      
      (name "Create cn=LDAP Monitor role")
      (dn (jinja "{{ [\"cn=LDAP Monitor\", \"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalRole")
      (attributes 
        (cn "LDAP Monitor")
        (description "Accounts which can read cn=Monitor information"))
      
      (name "Create cn=LDAP Editor role")
      (dn (jinja "{{ [\"cn=LDAP Editor\", \"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalRole")
      (attributes 
        (cn "LDAP Editor")
        (description "People responsible for LDAP contents"))
      
      (name "Create cn=UNIX Administrators group")
      (dn (jinja "{{ [\"cn=UNIX Administrators\", \"ou=Groups\"] + slapd__base_dn }}"))
      (objectClass (list
          "groupOfEntries"
          "posixGroup"
          "posixGroupId"
          "authorizedServiceObject"
          "hostObject"))
      (attributes 
        (cn "UNIX Administrators")
        (gid "admins")
        (gidNumber (jinja "{{ slapd__groupid_min }}"))
        (description "People responsible for UNIX-like infrastructure")
        (host "posix:all"))
      
      (name "Create cn=Account Administrator role")
      (dn (jinja "{{ [\"cn=Account Administrator\", \"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalRole")
      (attributes 
        (cn "Account Administrator")
        (description "People responsible for personal accounts"))
      
      (name "Create cn=Password Reset Agent role")
      (dn (jinja "{{ [\"cn=Password Reset Agent\", \"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalRole")
      (attributes 
        (cn "Password Reset Agent")
        (description "Services that can perform password changes on behalf of users"))
      
      (name "Create cn=SMS Gateway role")
      (dn (jinja "{{ [\"cn=SMS Gateway\", \"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalRole")
      (attributes 
        (cn "SMS Gateway")
        (description "Devices which send SMS messages to mobile numbers"))
      
      (name "Create cn=Hidden Object Viewer role")
      (dn (jinja "{{ [\"cn=Hidden Object Viewer\", \"ou=Roles\"] + slapd__base_dn }}"))
      (objectClass "organizationalRole")
      (attributes 
        (cn "Hidden Object Viewer")
        (memberOf (jinja "{{ ([\"cn=Hidden Objects\", \"ou=Groups\"] + slapd__base_dn) | join(\",\") }}"))
        (description "LDAP objects which can see hidden objects"))
      
      (name "Create cn=Hidden Objects group")
      (dn (jinja "{{ [\"cn=Hidden Objects\", \"ou=Groups\"] + slapd__base_dn }}"))
      (objectClass "groupOfNames")
      (attributes 
        (cn "Hidden Objects")
        (member (list
            (jinja "{{ ([\"cn=Hidden Objects\", \"ou=Groups\"] + slapd__base_dn) | join(\",\") }}")
            (jinja "{{ ([\"cn=Hidden Object Viewer\", \"ou=Roles\"] + slapd__base_dn) | join(\",\") }}")))
        (memberOf (jinja "{{ ([\"cn=Hidden Objects\", \"ou=Groups\"] + slapd__base_dn) | join(\",\") }}"))
        (description "LDAP objects which are accessible only by privileged accounts"))
      
      (name "Create cn=UNIX SSH users group")
      (dn (jinja "{{ [\"cn=UNIX SSH users\", \"ou=Groups\"] + slapd__base_dn }}"))
      (objectClass (list
          "groupOfEntries"
          "posixGroup"
          "posixGroupId"
          "authorizedServiceObject"
          "hostObject"))
      (attributes 
        (cn "UNIX SSH users")
        (gid "sshusers")
        (gidNumber (jinja "{{ slapd__groupid_min | int + 1 }}"))
        (description "People who can connect to UNIX-like infrastructure via SSH")
        (host "posix:all"))
      
      (name "Create cn=Next POSIX UID object")
      (dn (jinja "{{ [\"cn=Next POSIX UID\", \"ou=System\"] + slapd__base_dn }}"))
      (objectClass "uidNext")
      (attributes 
        (cn "Next POSIX UID")
        (uidNumber (jinja "{{ slapd__groupid_max | int + 2 }}"))
        (description "The next available uidNumber value"))
      
      (name "Create cn=Next POSIX GID object")
      (dn (jinja "{{ [\"cn=Next POSIX GID\", \"ou=System\"] + slapd__base_dn }}"))
      (objectClass "gidNext")
      (attributes 
        (cn "Next POSIX GID")
        (gidNumber (jinja "{{ slapd__groupid_min | int + 2 }}"))
        (description "The next available gidNumber value"))
      
      (name "Create SUDOers container")
      (dn (jinja "{{ [\"ou=SUDOers\"] + slapd__base_dn }}"))
      (objectClass "organizationalStructure")
      (attributes 
        (ou "SUDOers")
        (description "Container for sudoers.ldap(5) configuration"))
      
      (name "Create sudoer defaults LDAP entry")
      (dn (jinja "{{ [\"cn=defaults\", \"ou=SUDOers\"] + slapd__base_dn }}"))
      (objectClass "sudoRole")
      (attributes 
        (cn "defaults")
        (description "Object which contains default options for all sudo roles"))
      
      (name "Allow admins to gain root privileges via sudo")
      (dn (jinja "{{ [\"cn=%admins\", \"ou=SUDOers\"] + slapd__base_dn }}"))
      (objectClass "sudoRole")
      (attributes 
        (cn "%admins")
        (description "Grant privileged access to UNIX accounts in the \"admins\" UNIX group")
        (sudoUser "%admins")
        (sudoRunAsUser "ALL")
        (sudoRunAsGroup "ALL")
        (sudoHost "ALL")
        (sudoCommand "ALL")
        (sudoOption (list
            "!authenticate"
            "!requiretty"
            "env_check+=SSH_CLIENT")))))
  (slapd__tasks (list))
  (slapd__group_tasks (list))
  (slapd__host_tasks (list))
  (slapd__combined_tasks (jinja "{{ slapd__default_tasks
                           + slapd__acl_tasks
                           + slapd__cluster_tasks
                           + slapd__structure_tasks
                           + slapd__tasks
                           + slapd__group_tasks
                           + slapd__host_tasks }}"))
  (slapd__snapshot_deploy_state "present")
  (slapd__snapshot_cron_jobs (list
      "daily"
      "weekly"
      "monthly"))
  (slapd__services (list
      "ldap:///"
      (jinja "{{ \"ldaps:///\" if slapd__pki | bool else [] }}")
      "ldapi:///"))
  (slapd__ports (list
      "ldap"
      (jinja "{{ \"ldaps\" if slapd__pki | bool else [] }}")))
  (slapd__accept_any "False")
  (slapd__deny (list))
  (slapd__group_deny (list))
  (slapd__host_deny (list))
  (slapd__allow (list))
  (slapd__group_allow (list))
  (slapd__host_allow (list))
  (slapd__slapacl_deploy_state "present")
  (slapd__slapacl_test_objects_state "absent")
  (slapd__slapacl_run_tests "True")
  (slapd__slapacl_script "/etc/ldap/slapacl-test-suite")
  (slapd__slapacl_default_tasks (list
      
      (name "Manage LDAP Administrator object for ACL tests")
      (dn "uid=slapacl-test-ldap-admin,ou=People," (jinja "{{ slapd__basedn }}"))
      (objectClass (list
          "inetOrgPerson"))
      (attributes 
        (uid "slapacl-test-ldap-admin")
        (cn "LDAP Administrator")
        (surname "Administrator"))
      (state (jinja "{{ slapd__slapacl_test_objects_state }}"))
      
      (name "Manage cn=LDAP Administrator role")
      (dn "cn=LDAP Administrator,ou=Roles," (jinja "{{ slapd__basedn }}"))
      (attributes 
        (roleOccupant "uid=slapacl-test-ldap-admin,ou=People," (jinja "{{ slapd__basedn }}")))
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"ignore\" }}"))
      
      (name "Manage LDAP Editor object for ACL tests")
      (dn "uid=slapacl-test-ldap-editor,ou=People," (jinja "{{ slapd__basedn }}"))
      (objectClass (list
          "inetOrgPerson"))
      (attributes 
        (uid "slapacl-test-ldap-editor")
        (cn "LDAP Editor")
        (surname "Editor"))
      (state (jinja "{{ slapd__slapacl_test_objects_state }}"))
      
      (name "Manage cn=LDAP Editor role")
      (dn "cn=LDAP Editor,ou=Roles," (jinja "{{ slapd__basedn }}"))
      (attributes 
        (roleOccupant "uid=slapacl-test-ldap-editor,ou=People," (jinja "{{ slapd__basedn }}")))
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"ignore\" }}"))
      
      (name "Manage UNIX Administrator object for ACL tests")
      (dn "uid=slapacl-test-unix-admin,ou=People," (jinja "{{ slapd__basedn }}"))
      (objectClass (list
          "inetOrgPerson"))
      (attributes 
        (uid "slapacl-test-unix-admin")
        (cn "UNIX Administrator")
        (surname "Administrator"))
      (state (jinja "{{ slapd__slapacl_test_objects_state }}"))
      
      (name "Manage cn=UNIX Administrator group")
      (dn "cn=UNIX Administrators,ou=Groups," (jinja "{{ slapd__basedn }}"))
      (attributes 
        (member "uid=slapacl-test-unix-admin,ou=People," (jinja "{{ slapd__basedn }}")))
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"ignore\" }}"))
      
      (name "Manage Account Administrator object for ACL tests")
      (dn "uid=slapacl-test-account-admin,ou=People," (jinja "{{ slapd__basedn }}"))
      (objectClass (list
          "inetOrgPerson"))
      (attributes 
        (uid "slapacl-test-account-admin")
        (cn "Account Administrator")
        (surname "Administrator"))
      (state (jinja "{{ slapd__slapacl_test_objects_state }}"))
      
      (name "Manage cn=Account Administrator role")
      (dn "cn=Account Administrator,ou=Roles," (jinja "{{ slapd__basedn }}"))
      (attributes 
        (roleOccupant "uid=slapacl-test-account-admin,ou=People," (jinja "{{ slapd__basedn }}")))
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"ignore\" }}"))
      
      (name "Manage unprivileged user object for ACL tests")
      (dn "uid=slapacl-test-unpriv-user,ou=People," (jinja "{{ slapd__basedn }}"))
      (objectClass (list
          "inetOrgPerson"))
      (attributes 
        (uid "slapacl-test-unpriv-user")
        (cn "Unprivileged User")
        (surname "User"))
      (state (jinja "{{ slapd__slapacl_test_objects_state }}"))))
  (slapd__slapacl_tasks (list))
  (slapd__slapacl_group_tasks (list))
  (slapd__slapacl_host_tasks (list))
  (slapd__slapacl_combined_tasks (jinja "{{ slapd__slapacl_default_tasks
                                   + slapd__slapacl_tasks
                                   + slapd__slapacl_group_tasks
                                   + slapd__slapacl_host_tasks }}"))
  (slapd__slapacl_default_tests (list
      
      (name "Deny anonymous access to cn=config")
      (dn "cn=config")
      (authdn "")
      (policy "=0")
      (dry_run "True")
      
      (name "Allow administrator access to cn=config")
      (dn "cn=config")
      (authdn "cn=admin,cn=config")
      (policy "manage(=mwrscxd)")
      (dry_run "True")
      
      (name "Deny regular user access to cn=config")
      (dn "cn=config")
      (authdn "uid=slapacl-test-unpriv-user,ou=People," (jinja "{{ slapd__basedn }}"))
      (policy "=0")
      (dry_run "True")
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"init\" }}"))
      
      (name "Deny direct admin access to cn=config")
      (dn "cn=config")
      (authdn "uid=slapacl-test-ldap-admin,ou=People," (jinja "{{ slapd__basedn }}"))
      (policy "=0")
      (dry_run "True")
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"init\" }}"))
      
      (name "Deny anonymous access to cn=Monitor")
      (dn "cn=Monitor")
      (authdn "")
      (query "entry")
      (policy "none(=0)")
      (dry_run "True")
      
      (name "Deny anonymous access to base DN")
      (dn (jinja "{{ slapd__basedn }}"))
      (authdn "")
      (policy "none(=0)")
      
      (name "Allow authentication by anonymous users")
      (dn "uid=slapacl-test-unpriv-user,ou=People," (jinja "{{ slapd__basedn }}"))
      (authdn "")
      (query "userPassword")
      (policy "auth(=xd)")
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"init\" }}"))
      
      (name "Deny password read access by anonymous users")
      (dn "uid=slapacl-test-unpriv-user,ou=People," (jinja "{{ slapd__basedn }}"))
      (authdn "")
      (query "userPassword/read")
      (policy "denied")
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"init\" }}"))
      
      (name "Deny anonymous access to ou=People")
      (dn "ou=People," (jinja "{{ slapd__basedn }}"))
      (authdn "")
      (queries (list
          
          (name "entry")
          (result "entry: none(=0)")
          
          (name "children")
          (result "children: none(=0)")))
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"init\" }}"))
      
      (name "Deny write access to ou=People by unprivileged users")
      (dn "ou=People," (jinja "{{ slapd__basedn }}"))
      (authdn "uid=slapacl-test-unpriv-user,ou=People," (jinja "{{ slapd__basedn }}"))
      (query "entry/write")
      (policy "denied")
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"init\" }}"))
      
      (name "Allow write access to ou=People by administrators")
      (dn "ou=People," (jinja "{{ slapd__basedn }}"))
      (authdn "uid=slapacl-test-ldap-admin,ou=People," (jinja "{{ slapd__basedn }}"))
      (query "entry/write")
      (policy "allowed")
      (state (jinja "{{ \"present\"
               if (slapd__slapacl_test_objects_state == \"present\")
               else \"init\" }}"))))
  (slapd__slapacl_tests (list))
  (slapd__slapacl_group_tests (list))
  (slapd__slapacl_host_tests (list))
  (slapd__slapacl_combined_tests (jinja "{{ slapd__slapacl_default_tests
                                   + slapd__slapacl_tests
                                   + slapd__slapacl_group_tests
                                   + slapd__slapacl_host_tests }}"))
  (slapd__logrotate__dependent_config (list
      
      (filename "slapd")
      (sections (list
          
          (logs (jinja "{{ slapd__log_dir + \"/*.log\" }}"))
          (options "notifempty
missingok
weekly
maxsize 256M
rotate 120
compress
")
          (comment "OpenLDAP server logs")
          
          (logs (jinja "{{ slapd__log_dir + \"/*.ldif\" }}"))
          (options "notifempty
missingok
monthly
maxsize 256M
rotate 120
compress
")
          (comment "OpenLDAP audit logs")))))
  (slapd__python__dependent_packages3 (list
      (jinja "{{ []
        if (ansible_distribution_release in
            [\"stretch\", \"trusty\", \"xenial\"])
        else \"python3-ldap\" }}")))
  (slapd__python__dependent_packages2 (list
      "python-ldap"))
  (slapd__ferm__dependent_rules (list
      
      (name "reject_slapd")
      (type "accept")
      (protocol "tcp")
      (dport (jinja "{{ q(\"flattened\", slapd__ports) }}"))
      (multiport "True")
      (saddr (jinja "{{ slapd__deny + slapd__group_deny + slapd__host_deny }}"))
      (weight "45")
      (by_role "debops.slapd")
      (target "REJECT")
      (rule_state (jinja "{{ \"present\"
                    if (slapd__deny + slapd__group_deny + slapd__host_deny)
                    else \"absent\" }}"))
      
      (name "accept_slapd")
      (type "accept")
      (protocol "tcp")
      (dport (jinja "{{ q(\"flattened\", slapd__ports) }}"))
      (multiport "True")
      (saddr (jinja "{{ slapd__allow + slapd__group_allow + slapd__host_allow }}"))
      (accept_any (jinja "{{ slapd__accept_any }}"))
      (weight "50")
      (by_role "debops.slapd")))
  (slapd__tcpwrappers__dependent_allow (list
      
      (daemon "slapd")
      (client (jinja "{{ slapd__allow + slapd__group_allow + slapd__host_allow }}"))
      (default "ALL")
      (accept_any (jinja "{{ slapd__accept_any }}"))
      (weight "50")
      (filename "slapd_dependent_allow")
      (comment "Allow connections to OpenLDAP service")))
  (slapd__saslauthd__dependent_instances (list
      
      (name "slapd")
      (group (jinja "{{ slapd__group }}"))
      (description "OpenLDAP SASL Authentication Daemon")
      (config_path "/etc/ldap/sasl2/slapd.conf")
      (config_group (jinja "{{ slapd__group }}"))
      (config_raw "pwcheck_method: saslauthd
mech_list: PLAIN LOGIN EXTERNAL
saslauthd_path: /var/lib/slapd/saslauthd/mux
")
      (socket_path "/var/lib/slapd/saslauthd")
      (socket_group (jinja "{{ slapd__group }}"))
      (ldap_profile "slapd"))))
