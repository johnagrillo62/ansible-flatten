(playbook "debops/ansible/playbooks/service/nullmailer.yml"
    (play
    (name "Manage nullmailer SMTP server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_nullmailer"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare nullmailer environment"
        (ansible.builtin.import_role 
          (name "nullmailer")
          (tasks_from "main_env"))
        (tags (list
            "role::nullmailer"
            "role::ferm"
            "role::tcpwrappers"))))
    (roles
      
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
            (jinja "{{ nullmailer__ldap__dependent_tasks }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nullmailer__ferm__dependent_rules }}")))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers__dependent_allow (list
            (jinja "{{ nullmailer__tcpwrappers__dependent_allow }}")))
      
        (role "nullmailer")
        (tags (list
            "role::nullmailer"
            "skip::nullmailer")))))
