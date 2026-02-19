(playbook "debops/ansible/playbooks/service/slapd.yml"
    (play
    (name "Manage OpenLDAP service")
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
    (roles
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ slapd__ferm__dependent_rules }}")))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers__dependent_allow (list
            (jinja "{{ slapd__tcpwrappers__dependent_allow }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ slapd__logrotate__dependent_config }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::ldap"
            "role::slapd"))
        (python__dependent_packages3 (list
            (jinja "{{ ldap__python__dependent_packages3 }}")
            (jinja "{{ slapd__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ ldap__python__dependent_packages2 }}")
            (jinja "{{ slapd__python__dependent_packages2 }}")))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ saslauthd__ldap__dependent_tasks }}")))
        (when "slapd__saslauthd_enabled | bool")
      
        (role "saslauthd")
        (tags (list
            "role::saslauthd"
            "skip::saslauthd"))
        (saslauthd__dependent_instances (list
            (jinja "{{ slapd__saslauthd__dependent_instances }}")))
        (when "slapd__saslauthd_enabled | bool")
      
        (role "slapd")
        (tags (list
            "role::slapd"
            "skip::slapd")))))
