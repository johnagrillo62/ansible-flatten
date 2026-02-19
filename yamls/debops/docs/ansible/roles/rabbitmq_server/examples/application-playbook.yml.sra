(playbook "debops/docs/ansible/roles/rabbitmq_server/examples/application-playbook.yml"
    (play
    (name "Manage application")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_service_rabbitmq_application"))
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
      
        (role "rabbitmq_server")
        (tags (list
            "role::rabbitmq_server"))
        (rabbitmq_server__dependent_role "application")
        (rabbitmq_server__dependent_state (jinja "{{ application__deploy_state }}"))
        (rabbitmq_server__dependent_config (list
            (jinja "{{ application__rabbitmq_server__dependent_config }}")))
      
        (role "application")
        (tags (list
            "role::application")))))
