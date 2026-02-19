(playbook "debops/ansible/playbooks/service/kibana.yml"
    (play
    (name "Manage Kibana service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_kibana"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare kibana environment"
        (ansible.builtin.import_role 
          (name "kibana")
          (tasks_from "main_env"))
        (tags (list
            "role::kibana"
            "role::secret"
            "role::kibana:config"))))
    (roles
      
        (role "extrepo")
        (tags (list
            "role::extrepo"
            "skip::extrepo"
            "role::kibana"))
        (extrepo__dependent_sources (list
            (jinja "{{ kibana__extrepo__dependent_sources }}")))
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nginx"
            "role::elastic_co"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nginx__keyring__dependent_apt_keys }}")))
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::kibana"
            "role::kibana:config"))
        (secret__directories (list
            (jinja "{{ kibana__secret__directories }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ kibana__etc_services__dependent_list }}")))
      
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
            (jinja "{{ kibana__nginx__dependent_servers }}")))
        (nginx__dependent_upstreams (list
            (jinja "{{ kibana__nginx__dependent_upstreams }}")))
      
        (role "kibana")
        (tags (list
            "role::kibana"
            "skip::kibana")))))
