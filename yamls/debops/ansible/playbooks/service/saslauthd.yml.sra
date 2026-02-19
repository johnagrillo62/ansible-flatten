(playbook "debops/ansible/playbooks/service/saslauthd.yml"
    (play
    (name "Manage Cyrus SASL authentication service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_saslauthd"))
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
            (jinja "{{ saslauthd__ldap__dependent_tasks }}")))
      
        (role "saslauthd")
        (tags (list
            "role::saslauthd"
            "skip::saslauthd")))))
