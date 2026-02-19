(playbook "debops/ansible/playbooks/service/redis_sentinel.yml"
    (play
    (name "Manage Redis Sentinel service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_redis_sentinel"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare redis_sentinel environment"
        (ansible.builtin.import_role 
          (name "redis_sentinel")
          (tasks_from "main_env"))
        (tags (list
            "role::redis_sentinel"
            "role::ferm"))))
    (roles
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ redis_sentinel__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ redis_sentinel__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ redis_sentinel__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::redis_sentinel"))
        (python__dependent_packages3 (list
            (jinja "{{ redis_sentinel__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ redis_sentinel__python__dependent_packages2 }}")))
      
        (role "redis_sentinel")
        (tags (list
            "role::redis_sentinel"
            "skip::redis_sentinel")))))
