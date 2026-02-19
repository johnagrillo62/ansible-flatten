(playbook "debops/ansible/roles/mailman/defaults/main/ldap.yml"
  (mailman__ldap_enabled (jinja "{{ ansible_local.ldap.enabled | d(False) }}"))
  (mailman__ldap_uri (jinja "{{ ansible_local.ldap.uri | d([\"ldap://ldap.\" + ansible_domain]) }}"))
  (mailman__ldap_device_dn (jinja "{{ ansible_local.ldap.device_dn | d([]) }}"))
  (mailman__ldap_self_rdn "uid=mailman")
  (mailman__ldap_self_object_classes (list
      "account"
      "simpleSecurityObject"))
  (mailman__ldap_self_attributes 
    (uid (jinja "{{ mailman__ldap_self_rdn.split(\"=\")[1] }}"))
    (userPassword (jinja "{{ mailman__ldap_bind_password }}"))
    (host (jinja "{{ [ansible_fqdn, ansible_hostname] | unique }}"))
    (description "Account used by the \"mailman\" service to access the LDAP directory"))
  (mailman__ldap_starttls "True")
  (mailman__ldap_bind_dn (jinja "{{ ([mailman__ldap_self_rdn]
                            + mailman__ldap_device_dn) | join(\",\") }}"))
  (mailman__ldap_bind_password (jinja "{{ lookup(\"password\", secret + \"/ldap/credentials/\"
                                                    + mailman__ldap_bind_dn | to_uuid
                                                    + \".password chars=ascii_letters,digits length=22\") }}"))
  (mailman__ldap_base_dn (jinja "{{ ansible_local.ldap.basedn
                           if (ansible_local.ldap.basedn | d())
                           else \"dc=\" + ansible_domain.split(\".\")
                                        | join(\",dc=\") }}"))
  (mailman__ldap_people_rdn (jinja "{{ ansible_local.ldap.people_rdn | d(\"ou=People\") }}"))
  (mailman__ldap_groups_rdn (jinja "{{ ansible_local.ldap.groups_rdn | d(\"ou=Groups\") }}"))
  (mailman__ldap_people_dn (jinja "{{ mailman__ldap_people_rdn + \",\"
                             + mailman__ldap_base_dn }}"))
  (mailman__ldap_groups_dn (jinja "{{ mailman__ldap_groups_rdn + \",\"
                             + mailman__ldap_base_dn }}"))
  (mailman__ldap_people_filter "(& (objectClass=inetOrgPerson) (| (uid=%(user)s) (mail=%(user)s) ) (| (authorizedService=all) (authorizedService=mailman) ) )")
  (mailman__ldap_groups_filter "(objectClass=groupOfNames)")
  (mailman__ldap_superusers_group "cn=UNIX Administrators"))
