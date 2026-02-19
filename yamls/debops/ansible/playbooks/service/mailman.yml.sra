(playbook "debops/ansible/playbooks/service/mailman.yml"
    (play
    (name "Manage Mailman service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_mailman"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare postfix environment"
        (ansible.builtin.import_role 
          (name "postfix")
          (tasks_from "main_env"))
        (vars 
          (postfix__dependent_maincf (list
              
              (role "mailman")
              (config (jinja "{{ mailman__postfix__dependent_maincf }}")))))
        (tags (list
            "role::postfix"
            "role::secret"
            "role::ferm"))))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nginx"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::postfix"))
        (secret__directories (list
            (jinja "{{ postfix__secret__directories }}")))
      
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
            (jinja "{{ nginx__ferm__dependent_rules }}")
            (jinja "{{ postfix__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ ldap__python__dependent_packages3 | d([]) }}")
            (jinja "{{ nginx__python__dependent_packages3 }}")
            (jinja "{{ mailman__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ ldap__python__dependent_packages2 | d([]) }}")
            (jinja "{{ nginx__python__dependent_packages2 }}")
            (jinja "{{ mailman__python__dependent_packages2 }}")))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ mailman__ldap__dependent_tasks }}")))
        (when "mailman__ldap_enabled | bool")
      
        (role "postfix")
        (tags (list
            "role::postfix"
            "skip::postfix"))
        (postfix__dependent_maincf (list
            
            (role "mailman")
            (config (jinja "{{ mailman__postfix__dependent_maincf }}"))))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ mailman__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ mailman__nginx__dependent_upstreams }}")))
      
        (role "mailman")
        (tags (list
            "role::mailman"
            "skip::mailman")))))
