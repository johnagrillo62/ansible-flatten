(playbook "debops/ansible/playbooks/service/lvm.yml"
    (play
    (name "Configure Logical Volume Manager")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_lvm"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "lvm")
        (tags (list
            "role::lvm"
            "skip::lvm")))))
