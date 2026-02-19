(playbook "debops/ansible/playbooks/service/php.yml"
    (play
    (name "Install and manage PHP environment")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_php"))
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
              (jinja "{{ php__keyring__dependent_apt_keys }}"))))
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::php")))
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
            (jinja "{{ php__apt_preferences__dependent_list }}")))
      
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
            "skip::php")))))
