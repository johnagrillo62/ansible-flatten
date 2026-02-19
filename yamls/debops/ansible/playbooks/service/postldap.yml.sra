(playbook "debops/ansible/playbooks/service/postldap.yml"
    (play
    (name "Manage Postfix service with Virtual Mail LDAP backend")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_postldap"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare postfix environment"
        (ansible.builtin.import_role 
          (name "postfix")
          (tasks_from "main_env"))
        (vars 
          (postfix__dependent_packages (list
              (jinja "{{ postldap__postfix__dependent_packages }}")))
          (postfix__dependent_lookup_tables (list
              (jinja "{{ postldap__postfix__dependent_lookup_tables }}")))
          (postfix__dependent_maincf (list
              
              (role "postldap")
              (config (jinja "{{ postldap__postfix__dependent_maincf }}")))))
        (tags (list
            "role::postfix:env"
            "role::postfix"
            "role::postldap"
            "role::secret"
            "role::ferm"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::postfix"
            "role::postldap"))
        (secret__directories (list
            (jinja "{{ postfix__secret__directories }}")))
      
        (role "postldap")
        (tags (list
            "role::postldap"
            "skip::postldap"
            "role::postfix"))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ postldap__ldap__dependent_tasks }}")))
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
        (postfix__dependent_packages (list
            (jinja "{{ postldap__postfix__dependent_packages }}")))
        (postfix__dependent_lookup_tables (list
            (jinja "{{ postldap__postfix__dependent_lookup_tables }}")))
        (postfix__dependent_maincf (list
            
            (role "postldap")
            (config (jinja "{{ postldap__postfix__dependent_maincf }}")))))))
