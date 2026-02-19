(playbook "debops/ansible/roles/snapshot_snapper/docs/playbooks/snapshot_snapper.yml"
    (play
    (name "Configure volume snapshots with snapper")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_snapshot_snapper"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "snapshot_snapper")
        (tags (list
            "role::snapshot_snapper")))))
