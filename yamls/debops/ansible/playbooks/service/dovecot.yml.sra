(playbook "debops/ansible/playbooks/service/dovecot.yml"
    (play
    (name "Manage Dovecot service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_dovecot"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare dovecot environment"
        (ansible.builtin.import_role 
          (name "dovecot")
          (tasks_from "main_env"))
        (tags (list
            "role::dovecot"
            "role::secret"
            "role::ferm")))
      (task "Prepare postfix environment"
        (ansible.builtin.import_role 
          (name "postfix")
          (tasks_from "main_env"))
        (vars 
          (postfix__dependent_maincf (list
              
              (role "dovecot")
              (config (jinja "{{ dovecot__postfix__dependent_maincf }}"))))
          (postfix__dependent_mastercf (list
              
              (role "dovecot")
              (config (jinja "{{ dovecot__postfix__dependent_mastercf }}")))))
        (tags (list
            "role::postfix"
            "role::secret"
            "role::ferm"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::postfix"))
        (secret__directories (list
            (jinja "{{ postfix__secret__directories }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ dovecot__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ dovecot__ferm__dependent_rules }}")))
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
        (postfix__dependent_maincf (list
            
            (role "dovecot")
            (config (jinja "{{ dovecot__postfix__dependent_maincf }}"))))
        (postfix__dependent_mastercf (list
            
            (role "dovecot")
            (config (jinja "{{ dovecot__postfix__dependent_mastercf }}"))))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::ldap"))
        (python__dependent_packages3 (list
            (jinja "{{ ldap__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ ldap__python__dependent_packages2 }}")))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ dovecot__ldap__dependent_tasks }}")))
      
        (role "dovecot")
        (tags (list
            "role::dovecot"
            "skip::dovecot")))))
