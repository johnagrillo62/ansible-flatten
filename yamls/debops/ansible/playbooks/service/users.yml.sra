(playbook "debops/ansible/playbooks/service/users.yml"
    (play
    (name "Manage local users and groups")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_users"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "libuser")
        (tags (list
            "role::libuser"
            "skip::libuser"))
      
        (role "users")
        (tags (list
            "role::users"
            "skip::users")))))
