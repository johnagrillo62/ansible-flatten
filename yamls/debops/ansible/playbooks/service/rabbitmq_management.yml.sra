(playbook "debops/ansible/playbooks/service/rabbitmq_management.yml"
    (play
    (name "Configure RabbitMQ Management Console")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_rabbitmq_management"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare rabbitmq_server environment"
        (ansible.builtin.import_role 
          (name "rabbitmq_server")
          (tasks_from "main_env"))
        (tags (list
            "role::rabbitmq_server"
            "role::secret"
            "role::rabbitmq_server:config"))))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nginx"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::rabbitmq_server"
            "role::rabbitmq_server:config"))
        (secret__directories (list
            (jinja "{{ rabbitmq_server__secret__directories }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ rabbitmq_management__etc_services__dependent_list }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
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
            (jinja "{{ rabbitmq_management__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ rabbitmq_management__nginx__dependent_upstreams }}")))
      
        (role "rabbitmq_server")
        (tags (list
            "role::rabbitmq_server"
            "skip::rabbitmq_server"))
        (rabbitmq_server__dependent_role "rabbitmq_management")
        (rabbitmq_server__dependent_state (jinja "{{ rabbitmq_management__deploy_state }}"))
        (rabbitmq_server__dependent_config (list
            (jinja "{{ rabbitmq_management__rabbitmq_server__dependent_config }}")))
      
        (role "rabbitmq_management")
        (tags (list
            "role::rabbitmq_management"
            "skip::rabbitmq_management")))))
