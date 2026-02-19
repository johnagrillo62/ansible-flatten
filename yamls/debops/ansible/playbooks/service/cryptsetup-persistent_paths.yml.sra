(playbook "debops/ansible/playbooks/service/cryptsetup-persistent_paths.yml"
    (play
    (name "Setup and manage encrypted filesystems and ensure persistence")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_cryptsetup_persistent_paths"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "cryptsetup")
        (tags (list
            "role::cryptsetup"
            "skip::cryptsetup"))
      
        (role "persistent_paths")
        (tags (list
            "role::persistent_paths"
            "skip::persistent_paths"))
        (persistent_paths__dependent_paths (jinja "{{ cryptsetup__persistent_paths__dependent_paths }}")))))
