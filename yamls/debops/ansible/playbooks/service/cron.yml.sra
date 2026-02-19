(playbook "debops/ansible/playbooks/service/cron.yml"
    (play
    (name "Manage cron jobs")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_cron"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron")))))
