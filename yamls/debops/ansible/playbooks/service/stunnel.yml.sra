(playbook "debops/ansible/playbooks/service/stunnel.yml"
    (play
    (name "Configure stunnel")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_stunnel"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services_dependent_list (jinja "{{ stunnel_services }}"))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm_input_dependent_list (jinja "{{ stunnel_services }}"))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers_dependent_allow (jinja "{{ stunnel_services }}"))
      
        (role "stunnel")
        (tags (list
            "role::stunnel"
            "skip::stunnel")))))
