(playbook "debops/ansible/playbooks/service/tinc-persistent_paths.yml"
    (play
    (name "Configure Tinc VPN and ensure persistence")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_tinc_persistent_paths"
        "debops_service_tinc_aux"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare tinc environment"
        (ansible.builtin.import_role 
          (name "tinc")
          (tasks_from "main_env"))
        (tags (list
            "role::tinc"
            "role::tinc:secret"
            "role::secret"
            "role::ferm"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::tinc:secret"))
        (secret__directories (jinja "{{ tinc__env_secret__directories }}"))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (jinja "{{ tinc__env_etc_services__dependent_list }}"))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (jinja "{{ tinc__env_ferm__dependent_rules }}"))
      
        (role "tinc")
        (tags (list
            "role::tinc"
            "skip::tinc"))
      
        (role "persistent_paths")
        (tags (list
            "role::persistent_paths"
            "skip::persistent_paths"))
        (persistent_paths__dependent_paths (jinja "{{ tinc__persistent_paths__dependent_paths }}")))))
