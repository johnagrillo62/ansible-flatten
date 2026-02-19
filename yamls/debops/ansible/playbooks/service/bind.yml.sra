(playbook "debops/ansible/playbooks/service/bind.yml"
    (play
    (name "Manage BIND servers")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_bind"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"
            "role::nginx"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")
            (jinja "{{ bind__apt_preferences__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"
            "role::nginx"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")
            (jinja "{{ bind__ferm__dependent_rules }}")))
      
        (role "resolvconf")
        (tags (list
            "role::resolvconf"
            "skip::resolvconf"))
        (resolvconf__dependent_services (list
            "bind"))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ slapd__logrotate__dependent_config }}")))
        (when (list
            "\"dnssec\" in bind__features"
            "bind__dnssec_script_enabled | d(False)"))
      
        (role "bind")
        (tags (list
            "role::bind"
            "skip::bind"))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ bind__nginx__dependent_servers }}")))
        (when "ansible_local.nginx.enabled | d(False) or bind__features | intersect([ \"doh_proxy\", \"stats_proxy\" ]) | length > 0"))))
