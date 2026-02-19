(playbook "debops/ansible/roles/btrfs/docs/playbooks/btrfs.yml"
    (play
    (name "Manage Btrfs")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_btrfs"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "btrfs")
        (tags (list
            "role::btrfs")))))
