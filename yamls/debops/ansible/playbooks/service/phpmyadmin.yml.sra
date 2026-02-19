(playbook "debops/ansible/playbooks/service/phpmyadmin.yml"
    (play
    (name "Manage phpMyAdmin service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_phpmyadmin"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Apply keyring configuration for php environment"
        (ansible.builtin.import_role 
          (name "keyring"))
        (vars 
          (keyring__dependent_apt_keys (list
              (jinja "{{ php__keyring__dependent_apt_keys }}")
              (jinja "{{ nginx__keyring__dependent_apt_keys }}"))))
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::php"
            "role::nginx")))
      (task "Prepare php environment"
        (ansible.builtin.import_role 
          (name "php")
          (tasks_from "main_env"))
        (tags (list
            "role::php"
            "role::php:env"
            "role::logrotate"))))
    (roles
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ php__apt_preferences__dependent_list }}")
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ php__logrotate__dependent_config }}")))
      
        (role "php")
        (tags (list
            "role::php"
            "skip::php"))
        (php__dependent_packages (list
            (jinja "{{ phpmyadmin__php__dependent_packages }}")))
        (php__dependent_pools (list
            (jinja "{{ phpmyadmin__php__dependent_pools }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ nginx__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ phpmyadmin__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ phpmyadmin__nginx__dependent_upstreams }}")))
      
        (role "phpmyadmin")
        (tags (list
            "role::phpmyadmin"
            "skip::phpmyadmin")))))
