(playbook "debops/ansible/playbooks/service/fcgiwrap.yml"
    (play
    (name "Manage fcgiwrap instances")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_fcgiwrap"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "fcgiwrap")
        (tags (list
            "role::fcgiwrap"
            "skip::fcgiwrap")))))
