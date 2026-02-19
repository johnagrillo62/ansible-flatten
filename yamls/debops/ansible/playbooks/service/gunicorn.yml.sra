(playbook "debops/ansible/playbooks/service/gunicorn.yml"
    (play
    (name "Manage Green Unicorn service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_gunicorn"))
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
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ gunicorn__logrotate__dependent_config }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::gunicorn"))
        (python__dependent_packages3 (list
            (jinja "{{ gunicorn__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ gunicorn__python__dependent_packages2 }}")))
      
        (role "gunicorn")
        (tags (list
            "role::gunicorn"
            "skip::gunicorn")))))
