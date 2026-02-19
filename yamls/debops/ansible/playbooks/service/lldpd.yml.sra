(playbook "debops/ansible/playbooks/service/lldpd.yml"
    (play
    (name "Manage LLDP service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_lldpd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "lldpd")
        (tags (list
            "role::lldpd"
            "skip::lldpd")))))
