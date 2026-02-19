(playbook "debops/ansible/playbooks/service/postgresql_server.yml"
    (play
    (name "Manage PostgreSQL server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_postgresql_server"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::postgresql_server"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ postgresql_server__keyring__dependent_apt_keys }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ postgresql_server__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ postgresql_server__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::postgresql"))
        (python__dependent_packages3 (list
            (jinja "{{ postgresql_server__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ postgresql_server__python__dependent_packages2 }}")))
      
        (role "locales")
        (tags (list
            "role::locales"
            "skip::locales"))
        (locales__dependent_list (list
            (jinja "{{ postgresql_server__locales__dependent_list }}")))
      
        (role "postgresql_server")
        (tags (list
            "role::postgresql_server"
            "skip::postgresql_server")))))
