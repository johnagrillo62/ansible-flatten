(playbook "debops/ansible/playbooks/service/postfix.yml"
    (play
    (name "Manage Postfix SMTP service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_postfix"))
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
            "role::secret"
            "role::postfix")))
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
            (jinja "{{ etc_aliases__secret__directories }}")
            (jinja "{{ postfix__secret__directories }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ postfix__ferm__dependent_rules }}")))
      
        (role "etc_aliases")
        (tags (list
            "role::etc_aliases"
            "skip::etc_aliases"))
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix")))))
