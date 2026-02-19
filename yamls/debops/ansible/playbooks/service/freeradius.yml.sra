(playbook "debops/ansible/playbooks/service/freeradius.yml"
    (play
    (name "Manage FreeRADIUS service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_freeradius"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ freeradius__ferm__dependent_rules }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ freeradius__logrotate__dependent_config }}")))
      
        (role "freeradius")
        (tags (list
            "role::freeradius"
            "skip::freeradius")))))
