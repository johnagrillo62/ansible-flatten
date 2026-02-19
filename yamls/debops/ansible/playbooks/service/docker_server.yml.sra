(playbook "debops/ansible/playbooks/service/docker_server.yml"
    (play
    (name "Manage Docker server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_docker_server"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "extrepo")
        (tags (list
            "role::extrepo"
            "skip::extrepo"))
        (extrepo__dependent_sources (list
            (jinja "{{ docker_server__extrepo__dependent_sources }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"
            "role::ferm"))
        (etc_services__dependent_list (list
            (jinja "{{ docker_server__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ docker_server__ferm__dependent_rules }}")))
      
        (role "docker_server")
        (tags (list
            "role::docker_server"
            "skip::docker_server"))
      
        (role "systemd")
        (tags (list
            "role::systemd"
            "skip::systemd"))
        (systemd__dependent_units (list
            (jinja "{{ docker_server__systemd__dependent_units }}"))))))
