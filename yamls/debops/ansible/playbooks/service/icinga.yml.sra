(playbook "debops/ansible/playbooks/service/icinga.yml"
    (play
    (name "Configure Icinga service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_icinga"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare icinga environment"
        (ansible.builtin.import_role 
          (name "icinga")
          (tasks_from "main_env"))
        (tags (list
            "role::icinga"
            "role::secret"))))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::icinga"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ icinga__keyring__dependent_apt_keys }}")))
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::icinga"))
        (secret__directories (list
            (jinja "{{ icinga__secret__directories | d([]) }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ icinga__etc_services__dependent_list }}")))
      
        (role "unattended_upgrades")
        (tags (list
            "role::unattended_upgrades"
            "skip::unattended_upgrades"))
        (unattended_upgrades__dependent_origins (jinja "{{ icinga__unattended_upgrades__dependent_origins }}"))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ icinga__ferm__dependent_rules }}")))
      
        (role "icinga")
        (tags (list
            "role::icinga"
            "skip::icinga")))))
