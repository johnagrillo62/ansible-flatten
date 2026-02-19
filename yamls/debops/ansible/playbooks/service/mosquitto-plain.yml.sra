(playbook "debops/ansible/playbooks/service/mosquitto-plain.yml"
    (play
    (name "Configure Mosquitto service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_mosquitto"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::mosquitto"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ mosquitto__keyring__dependent_apt_keys }}")))
      
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
            (jinja "{{ mosquitto__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::mosquitto"))
        (python__dependent_packages3 (list
            (jinja "{{ mosquitto__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ mosquitto__python__dependent_packages2 }}")))
      
        (role "mosquitto")
        (tags (list
            "role::mosquitto"
            "skip::mosquitto")))))
