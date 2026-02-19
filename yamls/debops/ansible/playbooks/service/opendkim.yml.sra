(playbook "debops/ansible/playbooks/service/opendkim.yml"
    (play
    (name "Manage OpenDKIM service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_opendkim"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare opendkim environment"
        (ansible.builtin.import_role 
          (name "opendkim")
          (tasks_from "main_env"))
        (tags (list
            "role::opendkim"
            "role::secret")))
      (task "Prepare postfix environment"
        (ansible.builtin.import_role 
          (name "postfix")
          (tasks_from "main_env"))
        (vars 
          (postfix__dependent_maincf (list
              
              (role "opendkim")
              (config (jinja "{{ opendkim__postfix__dependent_maincf }}")))))
        (when "opendkim__postfix_integration | bool")
        (tags (list
            "role::postfix"
            "role::secret"
            "role::ferm"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::opendkim"
            "role::postfix"))
        (secret__directories (list
            (jinja "{{ postfix__secret__directories  | d([]) }}")
            (jinja "{{ opendkim__secret__directories | d([]) }}")))
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
        (postfix__dependent_maincf (list
            
            (role "opendkim")
            (config (jinja "{{ opendkim__postfix__dependent_maincf }}"))))
        (when "opendkim__postfix_integration | bool")
      
        (role "opendkim")
        (tags (list
            "role::opendkim"
            "skip::opendkim")))))
