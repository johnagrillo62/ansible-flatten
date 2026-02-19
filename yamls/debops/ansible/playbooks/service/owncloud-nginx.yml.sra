(playbook "debops/ansible/playbooks/service/owncloud-nginx.yml"
    (play
    (name "Install and manage ownCloud instances with Nginx as webserver")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_owncloud"
        "debops_service_owncloud_nginx"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Apply keyring configuration for php environment"
        (ansible.builtin.import_role 
          (name "keyring"))
        (vars 
          (keyring__dependent_apt_keys (list
              (jinja "{{ php__keyring__dependent_apt_keys }}")
              (jinja "{{ mariadb__keyring__dependent_apt_keys if (owncloud__database == \"mariadb\") else [] }}")
              (jinja "{{ postgresql__keyring__dependent_apt_keys if (owncloud__database == \"postgresql\") else [] }}")
              (jinja "{{ nginx__keyring__dependent_apt_keys }}")
              (jinja "{{ owncloud__keyring__dependent_apt_keys }}")))
          (keyring__dependent_gpg_keys (list
              (jinja "{{ owncloud__keyring__dependent_gpg_keys }}"))))
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::php"
            "role::mariadb"
            "role::postgresql"
            "role::nginx"
            "role::owncloud")))
      (task "Prepare php environment"
        (ansible.builtin.import_role 
          (name "php")
          (tasks_from "main_env"))
        (tags (list
            "role::php"
            "role::php:env"
            "role::logrotate")))
      (task "Prepare owncloud environment"
        (ansible.builtin.import_role 
          (name "owncloud")
          (tasks_from "main_env"))
        (tags (list
            "role::owncloud"
            "role::owncloud:env"
            "role::nginx"))))
    (roles
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"
            "role::nginx"
            "role::php"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")
            (jinja "{{ owncloud__apt_preferences__dependent_list }}")
            (jinja "{{ php__apt_preferences__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"
            "role::nginx"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::ldap"
            "role::mariadb"
            "role::postgresql"))
        (python__dependent_packages3 (list
            (jinja "{{ ldap__python__dependent_packages3 }}")
            (jinja "{{ mariadb__python__dependent_packages3
              if (owncloud__database == \"mariadb\")
              else [] }}")
            (jinja "{{ postgresql__python__dependent_packages3
              if (owncloud__database == \"postgresql\")
              else [] }}")
            (jinja "{{ nginx__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ ldap__python__dependent_packages2 }}")
            (jinja "{{ mariadb__python__dependent_packages2
              if (owncloud__database == \"mariadb\")
              else [] }}")
            (jinja "{{ postgresql__python__dependent_packages2
              if (owncloud__database == \"postgresql\")
              else [] }}")
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ owncloud__ldap__dependent_tasks }}")))
      
        (role "mariadb")
        (tags (list
            "role::mariadb"
            "skip::mariadb"))
        (mariadb__dependent_databases (jinja "{{ owncloud__mariadb__dependent_databases }}"))
        (mariadb__dependent_users (jinja "{{ owncloud__mariadb__dependent_users }}"))
        (when "(owncloud__database == 'mariadb')")
      
        (role "postgresql")
        (tags (list
            "role::postgresql"
            "skip::postgresql"))
        (postgresql__dependent_roles (jinja "{{ owncloud__postgresql__dependent_roles }}"))
        (postgresql__dependent_groups (jinja "{{ owncloud__postgresql__dependent_groups }}"))
        (postgresql__dependent_databases (jinja "{{ owncloud__postgresql__dependent_databases }}"))
        (when "(owncloud__database == 'postgresql')")
      
        (role "unattended_upgrades")
        (tags (list
            "role::unattended_upgrades"
            "skip::unattended_upgrades"))
        (unattended_upgrades__dependent_origins (jinja "{{ owncloud__unattended_upgrades__dependent_origins }}"))
      
        (role "php")
        (tags (list
            "role::php"
            "skip::php"))
        (php__dependent_packages (list
            (jinja "{{ owncloud__php__dependent_packages }}")))
        (php__dependent_configuration (list
            (jinja "{{ owncloud__php__dependent_configuration }}")))
        (php__dependent_pools (list
            (jinja "{{ owncloud__php__dependent_pools }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ php__logrotate__dependent_config }}")
            (jinja "{{ owncloud__logrotate__dependent_config }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_maps (list
            (jinja "{{ owncloud__nginx__dependent_maps }}")))
        (nginx__dependent_servers (list
            (jinja "{{ owncloud__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ owncloud__nginx__dependent_upstreams }}")))
      
        (role "owncloud")
        (tags (list
            "role::owncloud"
            "skip::owncloud")))))
