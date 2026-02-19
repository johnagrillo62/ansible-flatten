(playbook "debops/ansible/playbooks/service/rsnapshot.yml"
    (play
    (name "Manage rsnapshot service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_rsnapshot"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "rsnapshot")
        (tags (list
            "role::rsnapshot"
            "skip::rsnapshot")))))
