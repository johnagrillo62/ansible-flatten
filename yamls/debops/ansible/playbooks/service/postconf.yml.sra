(playbook "debops/ansible/playbooks/service/postconf.yml"
    (play
    (name "Manage Postfix configuration")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_postconf"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (vars
      (secret__directories (list
          (jinja "{{ postfix__secret__directories }}")))
      (ferm__dependent_rules (list
          (jinja "{{ postfix__ferm__dependent_rules }}")))
      (postfix__dependent_packages (list
          (jinja "{{ postconf__postfix__dependent_packages }}")))
      (postfix__dependent_maincf (list
          
          (role "postconf")
          (config (jinja "{{ postconf__postfix__dependent_maincf }}"))
          (state (jinja "{{ postconf__deploy_state }}"))))
      (postfix__dependent_mastercf (list
          
          (role "postconf")
          (config (jinja "{{ postconf__postfix__dependent_mastercf }}"))
          (state (jinja "{{ postconf__deploy_state }}"))))
      (postfix__dependent_lookup_tables (list
          (jinja "{{ postconf__postfix__dependent_lookup_tables }}"))))
    (pre_tasks
      (task "Prepare postconf environment"
        (ansible.builtin.import_role 
          (name "postconf")
          (tasks_from "main_env"))
        (tags (list
            "role::postconf"
            "role::postfix"
            "role::ferm")))
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
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
      
        (role "postconf")
        (tags (list
            "role::postconf"
            "skip::postconf")))))
