(playbook "debops/docs/ansible/roles/kibana/examples/application-playbook.yml"
    (play
    (name "Manage application")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_service_kibana_application"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare kibana environment"
        (ansible.builtin.import_role 
          (name "kibana")
          (tasks_from "main_env"))
        (tags (list
            "role::kibana"
            "role::secret"
            "role::kibana:config"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::kibana"
            "role::kibana:config"))
        (secret__directories (list
            (jinja "{{ kibana__secret__directories }}")))
      
        (role "kibana")
        (tags (list
            "role::kibana"))
        (kibana__dependent_role "application")
        (kibana__dependent_state (jinja "{{ application__deploy_state }}"))
        (kibana__dependent_configuration (list
            (jinja "{{ application__kibana__dependent_configuration }}")))
      
        (role "application")
        (tags (list
            "role::application")))))
