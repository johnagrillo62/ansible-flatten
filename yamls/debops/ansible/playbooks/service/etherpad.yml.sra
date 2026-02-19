(playbook "debops/ansible/playbooks/service/etherpad.yml"
    (play
    (name "Manage Etherpad service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_etherpad"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nodejs"
            "role::mariadb"
            "role::postgresql"
            "role::nginx"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nodejs__keyring__dependent_apt_keys }}")
            (jinja "{{ mariadb__keyring__dependent_apt_keys if (etherpad__database == \"mysql\") else [] }}")
            (jinja "{{ postgresql__keyring__dependent_apt_keys if (etherpad__database == \"postgresql\") else [] }}")
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ etherpad__etc_services__dependent_list }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ etherpad__logrotate__dependent_config }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")
            (jinja "{{ nodejs__apt_preferences__dependent_list }}")))
      
        (role "nodejs")
        (tags (list
            "role::nodejs"
            "skip::nodejs"))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::mariadb"
            "role::postgresql"))
        (python__dependent_packages3 (list
            (jinja "{{ postgresql__python__dependent_packages3 if etherpad__database == \"postgres\" else [] }}")
            (jinja "{{ mariadb__python__dependent_packages3 if etherpad__database == \"mysql\" else [] }}")
            (jinja "{{ nginx__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ postgresql__python__dependent_packages2 if etherpad__database == \"postgres\" else [] }}")
            (jinja "{{ mariadb__python__dependent_packages2 if etherpad__database == \"mysql\" else [] }}")
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
        (role "mariadb")
        (tags (list
            "role::mariadb"
            "skip::mariadb"))
        (mariadb__dependent_users (list
            (jinja "{{ etherpad__mariadb__dependent_users }}")))
        (mariadb__dependent_databases (list
            (jinja "{{ etherpad__mariadb__dependent_databases }}")))
        (when "etherpad__database == 'mysql'")
      
        (role "postgresql")
        (tags (list
            "role::postgresql"
            "skip::postgresql"))
        (postgresql__dependent_roles (list
            (jinja "{{ etherpad__postgresql__dependent_roles }}")))
        (postgresql__dependent_databases (list
            (jinja "{{ etherpad__postgresql__dependent_databases }}")))
        (when "etherpad__database == 'postgres'")
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ etherpad__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ etherpad__nginx__dependent_upstreams }}")))
      
        (role "etherpad")
        (tags (list
            "role::etherpad"
            "skip::etherpad")))))
