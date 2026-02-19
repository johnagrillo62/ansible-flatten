(playbook "debops/ansible/playbooks/ldap/save-credential.yml"
    (play
    (name "Save personal credential in the password store")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_slapd"))
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (vars
      (ldap__enabled "False")
      (person_rdn "uid=" (jinja "{{ person_uid.user_input }}"))
      (person_dn (jinja "{{ object_dn.user_input
                   if object_dn.user_input | d()
                   else ((([ person_rdn, ldap__people_rdn ] + ldap__base_dn) | join(\",\"))
                         if person_uid.user_input | d()
                         else \"\") }}"))
      (person_store_password (jinja "{{ lookup(\"passwordstore\", ldap__admin_passwordstore_path
                                      + \"/\" + (person_dn | to_uuid)
                                      + \" create=true overwrite=true userpass=\"
                                      + person_password) }}")))
    (pre_tasks
      (task "Specify username"
        (ansible.builtin.pause 
          (prompt "LDAP username (uid=%s," (jinja "{{ ([ldap__people_rdn] + ldap__base_dn) | join(\",\") }}") ")"))
        (register "person_uid")
        (delegate_to "localhost")
        (become "False")
        (run_once "True"))
      (task "Username not provided, specify DN"
        (ansible.builtin.pause 
          (prompt "LDAP Distinguished Name"))
        (register "object_dn")
        (when "person_uid is undefined or not person_uid.user_input | d()")
        (delegate_to "localhost")
        (become "False")
        (run_once "True"))
      (task "Make sure that we have a Distinguished Name"
        (ansible.builtin.assert 
          (that (list
              "person_dn | d()"))
          (fail_msg "No Distinguished Name provided, aborting")
          (success_msg "dn: " (jinja "{{ person_dn }}") " | UUID: " (jinja "{{ person_dn | to_uuid }}")))
        (delegate_to "localhost")
        (become "False")
        (run_once "True"))
      (task "Specify password"
        (ansible.builtin.pause 
          (prompt "LDAP password [random]")
          (echo "False"))
        (register "person_plaintext_password")
        (delegate_to "localhost")
        (become "False")
        (run_once "True"))
      (task "Generate random password if not specified"
        (ansible.builtin.set_fact 
          (person_password (jinja "{{ person_plaintext_password.user_input
                             if person_plaintext_password.user_input | d()
                             else lookup(\"password\", \"/dev/null length=42\") }}")))
        (delegate_to "localhost")
        (become "False")
        (run_once "True"))
      (task "Save credential in the password store"
        (ansible.builtin.set_fact 
          (person_saved_password (jinja "{{ person_store_password }}")))
        (no_log (jinja "{{ debops__no_log | d(True) }}"))
        (delegate_to "localhost")
        (become "False")
        (run_once "True")))
    (post_tasks
      (task "Display randomly generated password"
        (ansible.builtin.debug 
          (msg (jinja "{{ {\"Distinguished Name\": person_dn,
                  \"UUID\": (person_dn | to_uuid),
                  \"Stored password\": person_password} }}")))
        (when "not person_plaintext_password.user_input | d()")
        (delegate_to "localhost")
        (become "False")
        (run_once "True")))
    (roles
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap")))))
