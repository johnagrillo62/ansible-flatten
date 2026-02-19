(playbook "debops/ansible/playbooks/service/apt_cacher_ng.yml"
    (play
    (name "Install and manage the caching HTTP proxy Apt-Cacher NG.")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_apt_cacher_ng"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nginx"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ apt_cacher_ng__etc_services__dependent_list }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ apt_cacher_ng__apt_preferences__dependent_list }}")
            (jinja "{{ nginx_apt_preferences_dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ apt_cacher_ng__ferm__dependent_rules }}")
            (jinja "{{ nginx_ferm_dependent_rules }}")))
      
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
        (nginx_servers (list
            (jinja "{{ apt_cacher_ng__nginx__servers }}")))
        (nginx_upstreams (list
            (jinja "{{ apt_cacher_ng__nginx__upstream }}")))
      
        (role "apt_cacher_ng")
        (tags (list
            "role::apt_cacher_ng"
            "skip::apt_cacher_ng")))))
