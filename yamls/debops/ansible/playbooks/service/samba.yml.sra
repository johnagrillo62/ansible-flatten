(playbook "debops/ansible/playbooks/service/samba.yml"
    (play
    (name "Manage Samba service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_samba"))
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
            (jinja "{{ samba__ferm__dependent_rules }}")))
      
        (role "samba")
        (tags (list
            "role::samba"
            "skip::samba")))))
