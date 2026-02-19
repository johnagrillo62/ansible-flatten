(playbook "debops/ansible/playbooks/service/postscreen.yml"
    (play
    (name "Manage Postfix postscreen configuration")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_postscreen"))
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
          (postfix__dependent_packages (list
              (jinja "{{ postscreen__postfix__dependent_packages }}")))
          (postfix__dependent_maincf (list
              
              (role "postscreen")
              (config (jinja "{{ postscreen__postfix__dependent_maincf }}"))))
          (postfix__dependent_mastercf (list
              
              (role "postscreen")
              (config (jinja "{{ postscreen__postfix__dependent_mastercf }}")))))
        (tags (list
            "role::postfix"
            "role::secret"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::postfix"))
        (secret__directories (list
            (jinja "{{ postfix__secret__directories }}")))
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
        (postfix__dependent_packages (list
            (jinja "{{ postscreen__postfix__dependent_packages }}")))
        (postfix__dependent_maincf (list
            
            (role "postscreen")
            (config (jinja "{{ postscreen__postfix__dependent_maincf }}"))))
        (postfix__dependent_mastercf (list
            
            (role "postscreen")
            (config (jinja "{{ postscreen__postfix__dependent_mastercf }}"))))
      
        (role "postscreen")
        (tags (list
            "role::postscreen"
            "skip::postscreen")))))
