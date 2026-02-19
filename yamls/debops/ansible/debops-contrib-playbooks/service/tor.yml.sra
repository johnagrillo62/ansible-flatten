(playbook "debops/ansible/debops-contrib-playbooks/service/tor.yml"
    (play
    (name "Manage Tor relay")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_tor"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "secret")
        (tags (list
            "role::tor"))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ tor__ferm__dependent_rules }}")))
      
        (role "unattended_upgrades")
        (tags (list
            "role::unattended_upgrades"))
        (unattended_upgrades__dependent_origins (jinja "{{ tor__unattended_upgrades__dependent_origins }}"))
      
        (role "tor")
        (tags (list
            "role::tor")))))
