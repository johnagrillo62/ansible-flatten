(playbook "debops/docs/ansible/roles/postfix/examples/application-playbook.yml"
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
      (task "Prepare postfix environment"
        (ansible.builtin.import_role 
          (name "postfix")
          (tasks_from "main_env"))
        (tags (list
            "role::postfix"
            "role::secret"
            "role::ferm"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::postfix"))
        (secret__directories (list
            (jinja "{{ postfix__secret__directories }}")))
      
        (role "postfix")
        (tags (list
            "role::postfix"))
        (postfix__dependent_packages (list
            (jinja "{{ application__postfix__dependent_packages }}")))
        (postfix__dependent_maincf (list
            
            (application (jinja "{{ application__postfix__dependent_maincf }}"))))
        (postfix__dependent_mastercf (list
            
            (role "application")
            (config (jinja "{{ application__postfix__dependent_mastercf }}"))
            (state "present")))
      
        (role "application")
        (tags (list
            "role::application")))))
