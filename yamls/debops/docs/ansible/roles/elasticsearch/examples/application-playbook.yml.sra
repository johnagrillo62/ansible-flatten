(playbook "debops/docs/ansible/roles/elasticsearch/examples/application-playbook.yml"
    (play
    (name "Manage application")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_service_elasticsearch_application"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare elasticsearch environment"
        (ansible.builtin.import_role 
          (name "elasticsearch")
          (tasks_from "main_env"))
        (tags (list
            "role::elasticsearch"
            "role::secret"
            "role::elasticsearch:config"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::elasticsearch"
            "role::elasticsearch:config"))
        (secret__directories (list
            (jinja "{{ elasticsearch__secret__directories }}")))
      
        (role "elasticsearch")
        (tags (list
            "role::elasticsearch"))
        (elasticsearch__dependent_role "application")
        (elasticsearch__dependent_state (jinja "{{ application__deploy_state }}"))
        (elasticsearch__dependent_configuration (list
            (jinja "{{ application__elasticsearch__dependent_configuration }}")))
      
        (role "application")
        (tags (list
            "role::application")))))
