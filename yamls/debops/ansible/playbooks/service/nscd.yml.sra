(playbook "debops/ansible/playbooks/service/nscd.yml"
    (play
    (name "Manage Name Service Cache Daemon")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_nscd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "nscd")
        (tags (list
            "role::nscd"
            "skip::nscd")))))
