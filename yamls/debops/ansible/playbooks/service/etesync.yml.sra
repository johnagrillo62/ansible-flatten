(playbook "debops/ansible/playbooks/service/etesync.yml"
    (play
    (name "Deploy and manage the EteSync server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_etesync"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nginx"
            "role::etesync"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ etesync__keyring__dependent_gpg_keys }}")))
      
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
            "role::gunicorn"
            "role::etesync"))
        (python__dependent_packages3 (list
            (jinja "{{ gunicorn__python__dependent_packages3 }}")
            (jinja "{{ nginx__python__dependent_packages3 }}")
            (jinja "{{ etesync__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ gunicorn__python__dependent_packages2 }}")
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
        (role "gunicorn")
        (tags (list
            "role::gunicorn"
            "skip::gunicorn"))
        (gunicorn__dependent_applications (list
            (jinja "{{ etesync__gunicorn__dependent_applications }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_upstreams (list
            (jinja "{{ etesync__nginx__dependent_upstreams }}")))
        (nginx__dependent_servers (list
            (jinja "{{ etesync__nginx__dependent_servers }}")))
      
        (role "etesync")
        (tags (list
            "role::etesync"
            "skip::etesync")))))
