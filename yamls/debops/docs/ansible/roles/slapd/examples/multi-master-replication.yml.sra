(playbook "debops/docs/ansible/roles/slapd/examples/multi-master-replication.yml"
  (slapd__group_allow (list
      "192.0.2.0/24"))
  (slapd__cluster_tasks (list
      
      (name "Configure ServerID values")
      (dn "cn=config")
      (attributes 
        (olcServerID (list
            "001 ldap://slapd-server1.example.org/"
            "002 ldap://slapd-server2.example.org/"
            "003 ldap://slapd-server3.example.org/")))
      (state "exact")
      
      (name "Configure replication of the cn=config database")
      (dn "olcDatabase={0}config,cn=config")
      (attributes 
        (olcSyncrepl (list
            "{0}rid=000
   provider=\"ldap://slapd-server1.example.org/\"
   binddn=\"" (jinja "{{ slapd__config_rootdn }}") "\"
   bindmethod=\"simple\"
   credentials=\"" (jinja "{{ slapd__config_rootpw }}") "\"
   searchbase=\"cn=config\"
   type=\"refreshAndPersist\"
   retry=\"20 5 300 +\"
   timeout=\"4\"
   starttls=\"critical\"
   tls_cacert=\"" (jinja "{{ slapd__tls_ca_certificate }}") "\"
   tls_cert=\"" (jinja "{{ slapd__tls_certificate }}") "\"
   tls_key=\"" (jinja "{{ slapd__tls_private_key }}") "\"
   tls_cipher_suite=\"" (jinja "{{ slapd__tls_cipher_suite }}") "\""
            "{1}rid=001
   provider=\"ldap://slapd-server2.example.org/\"
   binddn=\"" (jinja "{{ slapd__config_rootdn }}") "\"
   bindmethod=\"simple\"
   credentials=\"" (jinja "{{ slapd__config_rootpw }}") "\"
   searchbase=\"cn=config\"
   type=\"refreshAndPersist\"
   retry=\"20 5 300 +\"
   timeout=\"4\"
   starttls=\"critical\"
   tls_cacert=\"" (jinja "{{ slapd__tls_ca_certificate }}") "\"
   tls_cert=\"" (jinja "{{ slapd__tls_certificate }}") "\"
   tls_key=\"" (jinja "{{ slapd__tls_private_key }}") "\"
   tls_cipher_suite=\"" (jinja "{{ slapd__tls_cipher_suite }}") "\""
            "{2}rid=002
   provider=\"ldap://slapd-server3.example.org/\"
   binddn=\"" (jinja "{{ slapd__config_rootdn }}") "\"
   bindmethod=\"simple\"
   credentials=\"" (jinja "{{ slapd__config_rootpw }}") "\"
   searchbase=\"cn=config\"
   type=\"refreshAndPersist\"
   retry=\"20 5 300 +\"
   timeout=\"4\"
   starttls=\"critical\"
   tls_cacert=\"" (jinja "{{ slapd__tls_ca_certificate }}") "\"
   tls_cert=\"" (jinja "{{ slapd__tls_certificate }}") "\"
   tls_key=\"" (jinja "{{ slapd__tls_private_key }}") "\"
   tls_cipher_suite=\"" (jinja "{{ slapd__tls_cipher_suite }}") "\""))
        (olcMirrorMode "TRUE"))
      (state "exact")
      
      (name "Configure time and size limits in the main database")
      (dn "olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcLimits (list
            "dn.exact=\"" (jinja "{{ slapd__data_rootdn }}") "\"
time=\"unlimited\"
size=\"unlimited\"")))
      (ordered "True")
      (state "exact")
      
      (name "Configure replication of the main database")
      (dn "olcDatabase={1}mdb,cn=config")
      (attributes 
        (olcSyncrepl (list
            "{0}rid=010
   provider=\"ldap://slapd-server1.example.org/\"
   binddn=\"" (jinja "{{ slapd__data_rootdn }}") "\"
   bindmethod=\"simple\"
   credentials=\"" (jinja "{{ slapd__data_rootpw }}") "\"
   searchbase=\"" (jinja "{{ slapd__basedn }}") "\"
   type=\"refreshAndPersist\"
   retry=\"20 5 300 +\"
   timeout=\"4\"
   starttls=\"critical\"
   tls_cacert=\"" (jinja "{{ slapd__tls_ca_certificate }}") "\"
   tls_cert=\"" (jinja "{{ slapd__tls_certificate }}") "\"
   tls_key=\"" (jinja "{{ slapd__tls_private_key }}") "\"
   tls_cipher_suite=\"" (jinja "{{ slapd__tls_cipher_suite }}") "\""
            "{1}rid=011
   provider=\"ldap://slapd-server2.example.org/\"
   binddn=\"" (jinja "{{ slapd__data_rootdn }}") "\"
   bindmethod=\"simple\"
   credentials=\"" (jinja "{{ slapd__data_rootpw }}") "\"
   searchbase=\"" (jinja "{{ slapd__basedn }}") "\"
   type=\"refreshAndPersist\"
   retry=\"20 5 300 +\"
   timeout=\"4\"
   starttls=\"critical\"
   tls_cacert=\"" (jinja "{{ slapd__tls_ca_certificate }}") "\"
   tls_cert=\"" (jinja "{{ slapd__tls_certificate }}") "\"
   tls_key=\"" (jinja "{{ slapd__tls_private_key }}") "\"
   tls_cipher_suite=\"" (jinja "{{ slapd__tls_cipher_suite }}") "\""
            "{2}rid=012
   provider=\"ldap://slapd-server3.example.org/\"
   binddn=\"" (jinja "{{ slapd__data_rootdn }}") "\"
   bindmethod=\"simple\"
   credentials=\"" (jinja "{{ slapd__data_rootpw }}") "\"
   searchbase=\"" (jinja "{{ slapd__basedn }}") "\"
   type=\"refreshAndPersist\"
   retry=\"20 5 300 +\"
   timeout=\"4\"
   starttls=\"critical\"
   tls_cacert=\"" (jinja "{{ slapd__tls_ca_certificate }}") "\"
   tls_cert=\"" (jinja "{{ slapd__tls_certificate }}") "\"
   tls_key=\"" (jinja "{{ slapd__tls_private_key }}") "\"
   tls_cipher_suite=\"" (jinja "{{ slapd__tls_cipher_suite }}") "\""))
        (olcMirrorMode "TRUE"))
      (state "exact"))))
