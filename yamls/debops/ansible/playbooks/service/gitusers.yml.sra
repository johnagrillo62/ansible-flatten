(playbook "debops/ansible/playbooks/service/gitusers.yml"
    (play
    (name "Manage users with git-shell accounts")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_gitusers"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "system_groups")
        (tags (list
            "role::system_groups"
            "skip::system_groups"))
      
        (role "gitusers")
        (tags (list
            "role::gitusers"
            "skip::gitusers"))
      
        (role "authorized_keys")
        (tags (list
            "role::authorized_keys"
            "skip::authorized_keys")))))
