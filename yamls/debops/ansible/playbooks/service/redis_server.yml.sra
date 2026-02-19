(playbook "debops/ansible/playbooks/service/redis_server.yml"
    (play
    (name "Manage Redis server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_redis_server"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare sysfs environment"
        (ansible.builtin.import_role 
          (name "sysfs")
          (tasks_from "main_env"))
        (tags (list
            "role::sysfs"
            "role::secret")))
      (task "Prepare redis_server environment"
        (ansible.builtin.import_role 
          (name "redis_server")
          (tasks_from "main_env"))
        (tags (list
            "role::redis_server"
            "role::ferm"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::sysfs"))
        (secret__directories (list
            (jinja "{{ sysfs__secret__directories | d([]) }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ redis_server__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ redis_server__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ redis_server__ferm__dependent_rules }}")))
      
        (role "sysctl")
        (tags (list
            "role::sysctl"
            "skip::sysctl"))
        (sysctl__dependent_parameters (list
            (jinja "{{ redis_server__sysctl__dependent_parameters }}")))
      
        (role "sysfs")
        (tags (list
            "role::sysfs"
            "skip::sysfs"))
        (sysfs__dependent_attributes (list
            (jinja "{{ redis_server__sysfs__dependent_attributes }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::redis_server"))
        (python__dependent_packages3 (list
            (jinja "{{ redis_server__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ redis_server__python__dependent_packages2 }}")))
      
        (role "redis_server")
        (tags (list
            "role::redis_server"
            "skip::redis_server")))))
