(playbook "debops/ansible/playbooks/service/miniflux.yml"
    (play
    (name "Manage Miniflux service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_miniflux"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::golang"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ miniflux__keyring__dependent_apt_keys }}")))
        (keyring__dependent_gpg_user (jinja "{{ golang__keyring__dependent_gpg_user }}"))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")
            (jinja "{{ golang__keyring__dependent_gpg_keys }}")))
        (golang__dependent_packages (list
            (jinja "{{ miniflux__golang__dependent_packages }}")))
      
        (role "postgresql")
        (tags (list
            "role::postgresql"
            "skip::postgresql"))
        (postgresql__dependent_roles (list
            (jinja "{{ miniflux__postgresql__dependent_roles }}")))
        (postgresql__dependent_groups (list
            (jinja "{{ miniflux__postgresql__dependent_groups }}")))
        (postgresql__dependent_databases (list
            (jinja "{{ miniflux__postgresql__dependent_databases }}")))
        (postgresql__dependent_extensions (list
            (jinja "{{ miniflux__postgresql__dependent_extensions }}")))
        (postgresql__dependent_pgpass (list
            (jinja "{{ miniflux__postgresql__dependent_pgpass }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ golang__apt_preferences__dependent_list }}")
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ miniflux__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ nginx__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ miniflux__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ miniflux__nginx__dependent_upstreams }}")))
      
        (role "golang")
        (tags (list
            "role::golang"
            "skip::golang"))
        (golang__dependent_packages (list
            (jinja "{{ miniflux__golang__dependent_packages }}")))
      
        (role "miniflux")
        (tags (list
            "role::miniflux"
            "skip::miniflux")))))
