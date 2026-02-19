(playbook "debops/ansible/playbooks/service/pki.yml"
    (play
    (name "Manage Public Key Infrastructure")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_pki"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare pki environment"
        (ansible.builtin.import_role 
          (name "pki")
          (tasks_from "main_env"))
        (tags (list
            "role::pki"
            "role::pki:secret"
            "role::secret"))))
    (roles
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::pki"
            "role::pki:secret"))
        (secret_directories (list
            (jinja "{{ pki_env_secret_directories }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "pki")
        (tags (list
            "role::pki"
            "skip::pki")))))
