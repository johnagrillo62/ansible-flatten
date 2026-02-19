(playbook "debops/ansible/playbooks/ldap/init-directory.yml"
    (play
    (name "Initialize new LDAP directory")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_slapd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (vars_prompt (list
        
        (name "admin_input_plaintext_password")
        (prompt "New password for your LDAP user account (enter=random)")
        (default "")
        (private "True")
        
        (name "admin_use_password_store")
        (default "yes")
        (prompt "Use Password Store? (default=yes)")))
    (vars
      (admin_user (jinja "{{ lookup(\"env\", \"USER\") }}"))
      (admin_gecos (jinja "{{ getent_passwd[admin_user][3] | d() }}"))
      (admin_sshkeys (jinja "{{ lookup(\"pipe\", \"ssh-add -L | grep ^\\\\\\(sk-\\\\\\)\\\\\\?ssh || cat ~/.ssh/*.pub || true\").split(\"\\n\") }}"))
      (admin_plaintext_password (jinja "{{ admin_input_plaintext_password
                                  if admin_input_plaintext_password | d()
                                  else (lookup(\"password\", \"/dev/null length=32\")
                                        if admin_use_password_store | d(True) | bool
                                        else
                                        lookup(\"password\",
                                               secret + \"/ldap/credentials/\"
                                               + admin_dn | to_uuid
                                               + \".password length=32\")) }}"))
      (admin_saved_password (jinja "{{ lookup(\"passwordstore\",
                                     ldap__admin_passwordstore_path
                                     + \"/\" + admin_dn | to_uuid
                                     + \" create=true overwrite=true userpass=\"
                                     + admin_plaintext_password) }}"))
      (admin_rdn "uid=" (jinja "{{ admin_user }}"))
      (admin_dn (jinja "{{ ([ admin_rdn, ldap__people_rdn ] + ldap__base_dn) | join(\",\") }}"))
      (ldap__enabled "True")
      (ldap__configured "True")
      (ldap__dependent_play "True")
      (ldap__servers (list
          (jinja "{{ ansible_fqdn }}")))
      (ldap__admin_binddn (jinja "{{ ([ \"cn=admin\" ] + ldap__base_dn) | join(\",\") }}"))
      (ldap__admin_bindpw (jinja "{{ lookup(\"password\", secret + \"/slapd/credentials/\"
                                   + ldap__admin_binddn | to_uuid
                                   + \".password\").split()[0] }}"))
      (ldap__dependent_tasks (list
          
          (name "Create personal account for " (jinja "{{ admin_user }}"))
          (dn (jinja "{{ [ admin_rdn, ldap__people_rdn ] + ldap__base_dn }}"))
          (objectClass (list
              "inetOrgPerson"
              "posixAccount"
              "shadowAccount"
              "posixGroup"
              "posixGroupId"
              "ldapPublicKey"
              "authorizedServiceObject"
              "hostObject"))
          (attributes 
            (commonName (jinja "{{ admin_gecos.split(\",\")[0] if admin_gecos | d() else (admin_user | capitalize) }}"))
            (givenName (jinja "{{ (admin_gecos.split(\",\")[0].split()[0]) if (admin_gecos | d() and \" \" in admin_gecos) else (admin_user | capitalize) }}"))
            (surname (jinja "{{ (admin_gecos.split(\",\")[0].split()[1]) if (admin_gecos | d() and \" \" in admin_gecos) else \"AdminUser\" }}"))
            (userPassword (jinja "{{ admin_plaintext_password }}"))
            (uid (jinja "{{ admin_rdn.split(\"=\")[1] }}"))
            (gid (jinja "{{ admin_rdn.split(\"=\")[1] }}"))
            (uidNumber (jinja "{{ ldap__groupid_max | int + 1 }}"))
            (gidNumber (jinja "{{ ldap__groupid_max | int + 1 }}"))
            (homeDirectory (jinja "{{ ldap__home + \"/\" + admin_user }}"))
            (loginShell (jinja "{{ ldap__shell }}"))
            (authorizedService "all")
            (host "posix:all")
            (sshPublicKey (jinja "{{ admin_sshkeys }}")))
          
          (name "Add admin account to cn=LDAP Administrator role")
          (dn (jinja "{{ [ \"cn=LDAP Administrator\", ldap__roles_rdn ] + ldap__base_dn }}"))
          (attributes 
            (roleOccupant (jinja "{{ admin_dn }}")))
          
          (name "Add admin account to cn=UNIX Administrators group")
          (dn (jinja "{{ [ \"cn=UNIX Administrators\", ldap__groups_rdn ] + ldap__base_dn }}"))
          (attributes 
            (member (jinja "{{ admin_dn }}"))
            (owner (jinja "{{ admin_dn }}"))))))
    (pre_tasks
      (task "Check local user information"
        (ansible.builtin.getent 
          (database "passwd")
          (key (jinja "{{ admin_user }}")))
        (delegate_to "localhost")
        (become "False")
        (failed_when "False"))
      (task "Save admin credential in the password store"
        (ansible.builtin.set_fact 
          (admin_stored_password (jinja "{{ admin_saved_password }}")))
        (when "admin_use_password_store | d(True) | bool")
        (no_log (jinja "{{ debops__no_log | d(True) }}"))
        (delegate_to "localhost")
        (become "False")
        (run_once "True")))
    (roles
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap")))))
