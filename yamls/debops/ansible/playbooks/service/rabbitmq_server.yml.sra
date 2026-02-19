(playbook "debops/ansible/playbooks/service/rabbitmq_server.yml"
    (play
    (name "Manage RabbitMQ service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_rabbitmq_server"))
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
            (jinja "{{ rabbitmq_server__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ rabbitmq_server__ferm__dependent_rules }}")))
      
        (role "rabbitmq_server")
        (tags (list
            "role::rabbitmq_server"
            "skip::rabbitmq_server")))))
