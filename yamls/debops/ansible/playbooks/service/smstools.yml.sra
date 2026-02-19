(playbook "debops/ansible/playbooks/service/smstools.yml"
    (play
    (name "Manage SMS Gateway service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_smstools"))
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
          (postfix__dependent_maincf (list
              
              (role "smstools")
              (config (jinja "{{ smstools__postfix__dependent_maincf }}"))))
          (postfix__dependent_mastercf (list
              
              (role "smstools")
              (config (jinja "{{ smstools__postfix__dependent_mastercf }}")))))
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
            (jinja "{{ smstools__etc_services__dependent_list }}")))
      
        (role "rsyslog")
        (tags (list
            "role::rsyslog"
            "skip::rsyslog"))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers__dependent_allow (list
            (jinja "{{ smstools__tcpwrappers__dependent_allow }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ postfix__ferm__dependent_rules }}")
            (jinja "{{ smstools__ferm__dependent_rules }}")))
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
        (postfix__dependent_maincf (list
            
            (role "smstools")
            (config (jinja "{{ smstools__postfix__dependent_maincf }}"))))
        (postfix__dependent_mastercf (list
            
            (role "smstools")
            (config (jinja "{{ smstools__postfix__dependent_mastercf }}"))))
      
        (role "smstools")
        (tags (list
            "role::smstools"
            "skip::smstools")))))
