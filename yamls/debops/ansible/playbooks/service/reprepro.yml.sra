(playbook "debops/ansible/playbooks/service/reprepro.yml"
    (play
    (name "Manage reprepro repositories")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_reprepro"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare reprepro environment"
        (ansible.builtin.import_role 
          (name "reprepro")
          (tasks_from "main_env"))
        (tags (list
            "role::reprepro"
            "role::nginx"))))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nginx"
            "role::reprepro"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
        (keyring__dependent_gpg_user (jinja "{{ reprepro__keyring__dependent_gpg_user }}"))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ reprepro__keyring__dependent_gpg_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ nginx__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ reprepro__nginx__dependent_servers }}")))
      
        (role "reprepro")
        (tags (list
            "role::reprepro"
            "skip::reprepro")))))
