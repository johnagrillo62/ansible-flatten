(playbook "debops/ansible/playbooks/service/extrepo.yml"
    (play
    (name "Manage external APT sources")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_extrepo"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "extrepo")
        (tags (list
            "role::extrepo"
            "skip::extrepo")))))
