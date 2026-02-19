(playbook "debops/ansible/playbooks/service/ntp.yml"
    (play
    (name "Manage Network Time Protocol service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_ntp"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ ntp__ferm__dependent_rules }}")))
      
        (role "ntp")
        (tags (list
            "role::ntp"
            "skip::ntp")))))
