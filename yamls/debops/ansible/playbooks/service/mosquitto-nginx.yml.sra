(playbook "debops/ansible/playbooks/service/mosquitto-nginx.yml"
    (play
    (name "Configure Mosquitto service with Nginx")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_mosquitto_nginx"))
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
            "role::mosquitto"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")
            (jinja "{{ mosquitto__keyring__dependent_apt_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ mosquitto__etc_services__dependent_list }}")))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers__dependent_allow (list
            (jinja "{{ mosquitto__tcpwrappers__dependent_allow }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ mosquitto__ferm__dependent_rules }}")
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::nginx"
            "role::mosquitto"))
        (python__dependent_packages3 (list
            (jinja "{{ nginx__python__dependent_packages3 }}")
            (jinja "{{ mosquitto__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ nginx__python__dependent_packages2 }}")
            (jinja "{{ mosquitto__python__dependent_packages2 }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ mosquitto__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ mosquitto__nginx__dependent_upstreams }}")))
      
        (role "mosquitto")
        (tags (list
            "role::mosquitto"
            "skip::mosquitto")))))
