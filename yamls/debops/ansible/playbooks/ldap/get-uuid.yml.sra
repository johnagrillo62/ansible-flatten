(playbook "debops/ansible/playbooks/ldap/get-uuid.yml"
    (play
    (name "Convert LDAP Distinguished Name to UUID")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "all"))
    (serial "1")
    (gather_subset (list
        "!all"))
    (vars
      (ldap_base_dn (jinja "{{ ansible_local.ldap.base_dn
                      if (ansible_local.ldap.base_dn | d())
                      else (ansible_domain.split(\".\")
                            | map(\"regex_replace\", \"^(.*)$\", \"dc=\\1\")
                            | list) }}"))
      (ldap_people_rdn (jinja "{{ ansible_local.ldap.people_rdn | d(\"ou=People\") }}"))
      (person_rdn "uid=" (jinja "{{ person_uid.user_input }}"))
      (object_dn (jinja "{{ (([ person_rdn, ldap_people_rdn ] + ldap_base_dn) | join(\",\"))
                   if person_uid.user_input | d()
                   else object_dn_string.user_input }}")))
    (tasks
      (task "Get the UUID of an user account based on uid"
        (ansible.builtin.pause 
          (prompt "uid (case-sensitive)"))
        (register "person_uid"))
      (task "Get the UUID of a Distinguished Name"
        (ansible.builtin.pause 
          (prompt "dn (case-sensitive)"))
        (register "object_dn_string")
        (when "not person_uid.user_input | d()"))
      (task "LDAP object information"
        (ansible.builtin.debug 
          (msg (jinja "{{ {\"DN:\": object_dn,
                  \"UUID:\": (object_dn | to_uuid)} }}")))
        (when "object_dn | d()")))))
