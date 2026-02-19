(playbook "debops/docs/ansible/roles/etc_aliases/examples/application-playbook.yml"
    (play
    (name "Manage application")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_service_application"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare etc_aliases environment"
        (ansible.builtin.import_role 
          (name "etc_aliases")
          (tasks_from "main_env"))
        (tags (list
            "role::etc_aliases"
            "role::secret"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::etc_aliases"))
        (secret__directories (list
            (jinja "{{ etc_aliases__secret__directories }}")))
      
        (role "etc_aliases")
        (tags (list
            "role::etc_aliases"))
        (etc_aliases__dependent_recipients (list
            
            (application (jinja "{{ application__etc_aliases__dependent_recipients }}"))
            
            (role "application")
            (config (jinja "{{ application__etc_aliases__dependent_recipients }}"))
            (state "present")))
      
        (role "application")
        (tags (list
            "role::application")))))
