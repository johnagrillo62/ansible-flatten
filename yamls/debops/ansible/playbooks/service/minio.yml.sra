(playbook "debops/ansible/playbooks/service/minio.yml"
    (play
    (name "Manage MinIO service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_minio"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare minio environment"
        (ansible.builtin.import_role 
          (name "minio")
          (tasks_from "main_env"))
        (tags (list
            "role::minio"
            "role::etc_services"
            "role::ferm"
            "role::keyring"
            "role::golang"
            "role::nginx")))
      (task "Prepare sysfs environment"
        (ansible.builtin.import_role 
          (name "sysfs")
          (tasks_from "main_env"))
        (tags (list
            "role::sysfs"
            "role::secret"))))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::golang"))
        (keyring__dependent_gpg_user (jinja "{{ golang__keyring__dependent_gpg_user }}"))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")
            (jinja "{{ golang__keyring__dependent_gpg_keys }}")))
        (golang__dependent_packages (list
            (jinja "{{ minio__golang__dependent_packages }}")))
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::sysfs"))
        (secret__directories (list
            (jinja "{{ sysfs__secret__directories | d([]) }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ golang__apt_preferences__dependent_list }}")
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ minio__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ minio__ferm__dependent_rules }}")
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "sysctl")
        (tags (list
            "role::sysctl"
            "skip::sysctl"))
        (sysctl__dependent_parameters (list
            (jinja "{{ minio__sysctl__dependent_parameters }}")))
      
        (role "sysfs")
        (tags (list
            "role::sysfs"
            "skip::sysfs"))
        (sysfs__dependent_attributes (list
            (jinja "{{ minio__sysfs__dependent_attributes }}")))
      
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
        (nginx__dependent_upstreams (list
            (jinja "{{ minio__nginx__dependent_upstreams }}")))
        (nginx__dependent_servers (list
            (jinja "{{ minio__nginx__dependent_servers }}")))
      
        (role "golang")
        (tags (list
            "role::golang"
            "skip::golang"))
        (golang__dependent_packages (list
            (jinja "{{ minio__golang__dependent_packages }}")))
      
        (role "minio")
        (tags (list
            "role::minio"
            "skip::minio")))))
