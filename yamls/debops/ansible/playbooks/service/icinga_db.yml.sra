(playbook "debops/ansible/playbooks/service/icinga_db.yml"
    (play
    (name "Configure Icinga database")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_icinga_db"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "mariadb")
        (tags (list
            "role::mariadb"
            "skip::mariadb"))
        (mariadb__dependent_databases (jinja "{{ icinga_db__mariadb__dependent_databases }}"))
        (mariadb__dependent_users (jinja "{{ icinga_db__mariadb__dependent_users }}"))
        (when "icinga_db__type == 'mariadb'")
      
        (role "postgresql")
        (tags (list
            "role::postgresql"
            "skip::postgresql"))
        (postgresql__dependent_roles (jinja "{{ icinga_db__postgresql__dependent_roles }}"))
        (postgresql__dependent_databases (jinja "{{ icinga_db__postgresql__dependent_databases }}"))
        (when "icinga_db__type == 'postgresql'")
      
        (role "icinga_db")
        (tags (list
            "role::icinga_db"
            "skip::icinga_db")))))
