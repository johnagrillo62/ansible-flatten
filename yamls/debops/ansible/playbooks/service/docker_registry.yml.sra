(playbook "debops/ansible/playbooks/service/docker_registry.yml"
    (play
    (name "Manage Docker Registry")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_docker_registry"))
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
            "role::docker_registry"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ docker_registry__keyring__dependent_gpg_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ golang__apt_preferences__dependent_list | d([]) }}")
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ docker_registry__etc_services__dependent_list }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::ldap"
            "role::docker_registry"))
        (python__dependent_packages3 (list
            (jinja "{{ ldap__python__dependent_packages3 }}")
            (jinja "{{ docker_registry__python__dependent_packages3 }}")
            (jinja "{{ nginx__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ ldap__python__dependent_packages2 }}")
            (jinja "{{ docker_registry__python__dependent_packages2 }}")
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
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
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_maps (list
            (jinja "{{ docker_registry__nginx__dependent_maps }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ docker_registry__nginx__dependent_upstreams }}")))
        (nginx__dependent_htpasswd (list
            (jinja "{{ docker_registry__nginx__dependent_htpasswd }}")))
        (nginx__dependent_servers (list
            (jinja "{{ docker_registry__nginx__dependent_servers }}")))
      
        (role "golang")
        (tags (list
            "role::golang"
            "skip::golang"))
        (when "docker_registry__upstream | bool")
      
        (role "docker_registry")
        (tags (list
            "role::docker_registry"
            "skip::docker_registry")))))
