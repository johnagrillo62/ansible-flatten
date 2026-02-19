(playbook "debops/ansible/playbooks/service/etc_aliases.yml"
    (play
    (name "Manage /etc/aliases database")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_etc_aliases"))
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
            "role::etc_aliases"
            "skip::etc_aliases")))))
