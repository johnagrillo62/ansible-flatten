(playbook "debops/ansible/playbooks/service/mount.yml"
    (play
    (name "Manage local device and bind mounts")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_mount"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "mount")
        (tags (list
            "role::mount"
            "skip::mount")))))
