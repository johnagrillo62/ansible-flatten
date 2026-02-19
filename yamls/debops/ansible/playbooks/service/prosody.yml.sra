(playbook "debops/ansible/playbooks/service/prosody.yml"
    (play
    (name "Manage Prosody")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_prosody"))
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
            (jinja "{{ prosody__ferm__dependent_rules }}")))
      
        (role "prosody")
        (tags (list
            "role::prosody"
            "skip::prosody")))))
