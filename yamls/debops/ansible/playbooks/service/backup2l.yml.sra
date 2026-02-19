(playbook "debops/ansible/playbooks/service/backup2l.yml"
    (play
    (name "Configure backup2l service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_backup2l"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "backup2l")
        (tags (list
            "role::backup2l"
            "skip::backup2l")))))
