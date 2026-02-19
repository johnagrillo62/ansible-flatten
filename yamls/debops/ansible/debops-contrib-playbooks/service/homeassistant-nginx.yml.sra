(playbook "debops/ansible/debops-contrib-playbooks/service/homeassistant-nginx.yml"
    (play
    (name "Setup and manage Home Assistant with Nginx as reverse proxy")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_homeassistant_nginx"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare homeassistant environment"
        (ansible.builtin.import_role 
          (name "homeassistant")
          (tasks_from "main_env"))
        (tags (list
            "role::homeassistant"
            "role::nginx"))))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nginx"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"))
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
            "role::nginx"))
        (nginx__dependent_upstreams (list
            (jinja "{{ homeassistant__nginx__dependent_upstreams }}")))
        (nginx__dependent_htpasswd (list
            (jinja "{{ homeassistant__nginx__dependent_htpasswd }}")))
        (nginx__dependent_servers (list
            (jinja "{{ homeassistant__nginx__dependent_servers }}")))
      
        (role "homeassistant")
        (tags (list
            "role::homeassistant")))))
