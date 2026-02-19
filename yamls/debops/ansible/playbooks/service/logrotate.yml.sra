(playbook "debops/ansible/playbooks/service/logrotate.yml"
    (play
    (name "Manage log rotation configuration")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_logrotate"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate")))))
