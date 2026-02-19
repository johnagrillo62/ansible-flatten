(playbook "debops/ansible/playbooks/service/swapfile.yml"
    (play
    (name "Configure swap files")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_swapfile"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "swapfile")
        (tags (list
            "role::swapfile"
            "skip::swapfile")))))
