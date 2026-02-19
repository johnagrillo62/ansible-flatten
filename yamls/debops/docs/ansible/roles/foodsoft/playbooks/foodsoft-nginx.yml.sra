(playbook "debops/docs/ansible/roles/foodsoft/playbooks/foodsoft-nginx.yml"
    (play
    (name "Setup and manage Foodsoft with Nginx as webserver")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_foodsoft_nginx"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "mariadb")
        (tags (list
            "role::mariadb"))
        (mariadb__dependent_databases (jinja "{{ foodsoft__mariadb__dependent_databases }}"))
        (mariadb__dependent_users (jinja "{{ foodsoft__mariadb__dependent_users }}"))
        (when "(foodsoft__database == 'mariadb')")
      
        (role "ruby")
        (tags (list
            "role::ruby"))
      
        (role "nginx")
        (tags (list
            "role::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ foodsoft__nginx__dependent_servers }}")))
      
        (role "foodsoft")
        (tags (list
            "role::foodsoft")))))
