(playbook "debops/ansible/playbooks/service/keepalived.yml"
    (play
    (name "Manage Advanced Package Manager")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_keepalived"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "sysctl")
        (tags (list
            "role::sysctl"
            "skip::sysctl"))
        (sysctl__dependent_parameters (list
            (jinja "{{ keepalived__sysctl__dependent_parameters }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ keepalived__ferm__dependent_rules }}")))
      
        (role "keepalived")
        (tags (list
            "role::keepalived"
            "skip::keepalived")))))
