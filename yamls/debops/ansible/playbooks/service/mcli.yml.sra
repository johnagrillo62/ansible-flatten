(playbook "debops/ansible/playbooks/service/mcli.yml"
    (play
    (name "Manage MinIO Client (mcli) installation")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_mcli"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare mcli environment"
        (ansible.builtin.import_role 
          (name "mcli")
          (tasks_from "main_env"))
        (tags (list
            "role::mcli"
            "role::keyring"
            "role::golang"))))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::golang"))
        (keyring__dependent_gpg_user (jinja "{{ golang__keyring__dependent_gpg_user }}"))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ golang__keyring__dependent_gpg_keys }}")))
        (golang__dependent_packages (list
            (jinja "{{ mcli__golang__dependent_packages }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ golang__apt_preferences__dependent_list }}")))
      
        (role "golang")
        (tags (list
            "role::golang"
            "skip::golang"))
        (golang__dependent_packages (list
            (jinja "{{ mcli__golang__dependent_packages }}")))
      
        (role "mcli")
        (tags (list
            "role::mcli"
            "skip::mcli")))))
