(playbook "debops/ansible/playbooks/service/roundcube.yml"
    (play
    (name "Install and manage Roundcube Web mail")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_roundcube"))
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
              (jinja "{{ nodejs__keyring__dependent_apt_keys }}")
              (jinja "{{ nginx__keyring__dependent_apt_keys }}")
              (jinja "{{ mariadb__keyring__dependent_apt_keys }}")))
          (keyring__dependent_gpg_user (jinja "{{ roundcube__keyring__dependent_gpg_user }}"))
          (keyring__dependent_gpg_keys (list
              (jinja "{{ roundcube__keyring__dependent_gpg_keys }}"))))
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::php"
            "role::nodejs"
            "role::nginx"
            "role::mariadb"
            "role::roundcube")))
      (task "Prepare php environment"
        (ansible.builtin.import_role 
          (name "php")
          (tasks_from "main_env"))
        (tags (list
            "role::php"
            "role::php:env"
            "role::logrotate"))))
    (roles
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"
            "role::nginx"
            "role::php"
            "role::nodejs"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")
            (jinja "{{ php__apt_preferences__dependent_list }}")
            (jinja "{{ nodejs__apt_preferences__dependent_list }}")))
      
        (role "cron")
        (tags (list
            "role::cron"
            "skip::cron"))
      
        (role "logrotate")
        (tags (list
            "role::logrotate"
            "skip::logrotate"))
        (logrotate__dependent_config (list
            (jinja "{{ php__logrotate__dependent_config }}")))
      
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
            "role::mariadb"
            "role::postgresql"))
        (python__dependent_packages3 (list
            (jinja "{{ ldap__python__dependent_packages3 }}")
            (jinja "{{ mariadb__python__dependent_packages3 if roundcube__database_map[roundcube__database].dbtype == \"mysql\" else [] }}")
            (jinja "{{ nginx__python__dependent_packages3 }}")
            (jinja "{{ postgresql__python__dependent_packages3 if roundcube__database_map[roundcube__database].dbtype == \"postgresql\" else [] }}")))
        (python__dependent_packages2 (list
            (jinja "{{ ldap__python__dependent_packages2 }}")
            (jinja "{{ mariadb__python__dependent_packages2 if roundcube__database_map[roundcube__database].dbtype == \"mysql\" else [] }}")
            (jinja "{{ nginx__python__dependent_packages2 }}")
            (jinja "{{ postgresql__python__dependent_packages2 if roundcube__database_map[roundcube__database].dbtype == \"postgresql\" else [] }}")))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ roundcube__ldap__dependent_tasks }}")))
      
        (role "php")
        (tags (list
            "role::php"
            "skip::php"))
        (php__dependent_packages (list
            (jinja "{{ roundcube__php__dependent_packages }}")))
        (php__dependent_pools (list
            (jinja "{{ roundcube__php__dependent_pools }}")))
      
        (role "nodejs")
        (tags (list
            "role::nodejs"
            "skip::nodejs"))
        (nodejs__npm_dependent_packages (list
            (jinja "{{ roundcube__nodejs__npm_dependent_packages }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ roundcube__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ roundcube__nginx__dependent_upstreams }}")))
      
        (role "mariadb")
        (tags (list
            "role::mariadb"
            "skip::mariadb"))
        (mariadb__dependent_users (list
            
            (database (jinja "{{ roundcube__database_map[roundcube__database].dbname }}"))
            (user (jinja "{{ roundcube__database_map[roundcube__database].dbuser }}"))
            (password (jinja "{{ roundcube__database_map[roundcube__database].dbpass }}"))
            (owner (jinja "{{ roundcube__user }}"))
            (group (jinja "{{ roundcube__group }}"))
            (home (jinja "{{ roundcube__home }}"))
            (system "True")
            (priv_aux "False")))
        (mariadb__server (jinja "{{ roundcube__database_map[roundcube__database].dbhost }}"))
        (when "roundcube__database_map[roundcube__database].dbtype == 'mysql'")
      
        (role "postgresql")
        (tags (list
            "role::postgresql"
            "skip::postgresql"))
        (postgresql__dependent_roles (list
            
            (db (jinja "{{ roundcube__database_map[roundcube__database].dbname }}"))
            (role (jinja "{{ roundcube__database_map[roundcube__database].dbuser }}"))
            (password (jinja "{{ roundcube__database_map[roundcube__database].dbpass }}"))))
        (postgresql__server (jinja "{{ roundcube__database_map[roundcube__database].dbhost
                              if roundcube__database_map[roundcube__database].dbhost != \"localhost\"
                              else \"\" }}"))
        (when "roundcube__database_map[roundcube__database].dbtype == 'postgresql'")
      
        (role "roundcube")
        (tags (list
            "role::roundcube"
            "skip::roundcube")))))
