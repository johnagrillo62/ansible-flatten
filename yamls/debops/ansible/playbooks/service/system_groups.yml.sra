(playbook "debops/ansible/playbooks/service/system_groups.yml"
    (play
    (name "Configure UNIX system groups")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_system_groups"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
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
            (jinja "{{ sudo__ldap__dependent_tasks }}")))
      
        (role "sudo")
        (tags (list
            "role::sudo"
            "skip::sudo"))
      
        (role "system_groups")
        (tags (list
            "role::system_groups"
            "skip::system_groups")))))
