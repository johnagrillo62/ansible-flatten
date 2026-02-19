(playbook "debops/ansible/playbooks/service/persistent_paths.yml"
    (play
    (name "Ensure paths are stored on persistent storage")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_persistent_paths"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "persistent_paths")
        (tags (list
            "role::persistent_paths"
            "skip::persistent_paths")))))
