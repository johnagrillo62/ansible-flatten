(playbook "debops/ansible/playbooks/service/dhparam.yml"
    (play
    (name "Manage Diffie-Hellman parameters")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_dhparam"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "dhparam")
        (tags (list
            "role::dhparam"
            "skip::dhparam")))))
