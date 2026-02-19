(playbook "debops/ansible/playbooks/service/radvd.yml"
    (play
    (name "Configure Router Advertisement Daemon")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_radvd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "radvd")
        (tags (list
            "role::radvd"
            "skip::radvd")))))
