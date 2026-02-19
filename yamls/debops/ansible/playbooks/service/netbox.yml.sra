(playbook "debops/ansible/playbooks/service/netbox.yml"
    (play
    (name "Manage NetBox IPAM/DCIM application")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_netbox"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::postgresql"
            "role::nginx"
            "role::netbox"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ postgresql__keyring__dependent_apt_keys }}")
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ netbox__keyring__dependent_gpg_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ gunicorn__logrotate__dependent_config }}")))
      
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
            "role::postgresql"
            "role::gunicorn"
            "role::netbox"))
        (python__dependent_packages3 (list
            (jinja "{{ gunicorn__python__dependent_packages3 }}")
            (jinja "{{ ldap__python__dependent_packages3 }}")
            (jinja "{{ netbox__python__dependent_packages3 }}")
            (jinja "{{ nginx__python__dependent_packages3 }}")
            (jinja "{{ postgresql__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ gunicorn__python__dependent_packages2 }}")
            (jinja "{{ ldap__python__dependent_packages2 }}")
            (jinja "{{ netbox__python__dependent_packages2 }}")
            (jinja "{{ nginx__python__dependent_packages2 }}")
            (jinja "{{ postgresql__python__dependent_packages2 }}")))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ netbox__ldap__dependent_tasks }}")))
      
        (role "postgresql")
        (tags (list
            "role::postgresql"
            "skip::postgresql"))
        (postgresql__dependent_roles (list
            (jinja "{{ netbox__postgresql__dependent_roles }}")))
        (postgresql__dependent_groups (list
            (jinja "{{ netbox__postgresql__dependent_groups }}")))
        (postgresql__dependent_databases (list
            (jinja "{{ netbox__postgresql__dependent_databases }}")))
        (postgresql__dependent_pgpass (list
            (jinja "{{ netbox__postgresql__dependent_pgpass }}")))
      
        (role "gunicorn")
        (tags (list
            "role::gunicorn"
            "skip::gunicorn"))
        (gunicorn__dependent_applications (list
            (jinja "{{ netbox__gunicorn__dependent_applications }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_upstreams (list
            (jinja "{{ netbox__nginx__dependent_upstreams }}")))
        (nginx__dependent_servers (list
            (jinja "{{ netbox__nginx__dependent_servers }}")))
      
        (role "netbox")
        (tags (list
            "role::netbox"
            "skip::netbox")))))
