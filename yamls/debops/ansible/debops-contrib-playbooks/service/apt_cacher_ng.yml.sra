(playbook "debops/ansible/debops-contrib-playbooks/service/apt_cacher_ng.yml"
    (play
    (name "Install and manage the caching HTTP proxy Apt-Cacher NG.")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_contrib_service_apt_cacher_ng"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "etc_services")
        (tags (list
            "role::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ apt_cacher_ng__etc_services__dependent_list }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"))
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
      
        (role "nginx")
        (tags (list
            "role::nginx"))
        (nginx_servers (list
            (jinja "{{ apt_cacher_ng__nginx__servers }}")))
        (nginx_upstreams (list
            (jinja "{{ apt_cacher_ng__nginx__upstream }}")))
      
        (role "apparmor")
        (tags (list
            "role::apparmor"))
        (apparmor__local_dependent_config (jinja "{{ apt_cacher_ng__apparmor__dependent_config }}"))
        (apparmor__tunables_dependent (jinja "{{ apt_cacher_ng__apparmor__tunables_dependent }}"))
      
        (role "apt_cacher_ng")
        (tags (list
            "role::apt_cacher_ng")))))
