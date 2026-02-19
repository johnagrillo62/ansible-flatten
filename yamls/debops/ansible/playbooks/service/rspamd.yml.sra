(playbook "debops/ansible/playbooks/service/rspamd.yml"
    (play
    (name "Manage rspamd service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_rspamd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare postfix environment"
        (ansible.builtin.import_role 
          (name "postfix")
          (tasks_from "main_env"))
        (vars 
          (postfix__dependent_maincf (list
              
              (role "rspamd")
              (config (jinja "{{ rspamd__postfix__dependent_maincf }}")))))
        (tags (list
            "role::postfix"))))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nginx"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ rspamd__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")
            (jinja "{{ rspamd__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ nginx__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ rspamd__logrotate__dependent_config }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ rspamd__nginx__dependent_servers }}")))
        (when "rspamd__nginx_enabled | d(False) | bool")
      
        (role "rspamd")
        (tags (list
            "role::rspamd"
            "skip::rspamd"))
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
        (postfix__dependent_maincf (list
            
            (role "rspamd")
            (config (jinja "{{ rspamd__postfix__dependent_maincf }}")))))))
