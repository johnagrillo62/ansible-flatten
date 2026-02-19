(playbook "debops/ansible/playbooks/service/grub.yml"
    (play
    (name "Configure GRUB")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_grub"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "grub")
        (tags (list
            "role::grub"
            "skip::grub")))))
