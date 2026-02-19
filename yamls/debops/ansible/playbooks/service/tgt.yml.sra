(playbook "debops/ansible/playbooks/service/tgt.yml"
    (play
    (name "Manage iSCSI Target service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_tgt"))
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
            (jinja "{{ tgt__ferm__dependent_rules }}")))
      
        (role "tgt")
        (tags (list
            "role::tgt"
            "skip::tgt")))))
