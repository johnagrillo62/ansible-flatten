(playbook "debops/ansible/playbooks/service/elasticsearch.yml"
    (play
    (name "Manage Elasticsearch cluster")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_elasticsearch"
        "debops_service_elasticsearch_master"
        "debops_service_elasticsearch_data"
        "debops_service_elasticsearch_ingest"
        "debops_service_elasticsearch_lb"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare elasticsearch environment"
        (ansible.builtin.import_role 
          (name "elasticsearch")
          (tasks_from "main_env"))
        (tags (list
            "role::elasticsearch"
            "role::secret"
            "role::elasticsearch:config"))))
    (roles
      
        (role "extrepo")
        (tags (list
            "role::extrepo"
            "skip::extrepo"
            "role::elasticsearch"))
        (extrepo__dependent_sources (list
            (jinja "{{ elasticsearch__extrepo__dependent_sources }}")))
      
        (role "secret")
        (tags (list
            "role::secret"
            "role::elasticsearch"
            "role::elasticsearch:config"))
        (secret__directories (list
            (jinja "{{ elasticsearch__secret__directories }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ elasticsearch__etc_services__dependent_list }}")))
      
        (role "sysctl")
        (tags (list
            "role::sysctl"
            "skip::sysctl"))
        (sysctl__dependent_parameters (list
            (jinja "{{ elasticsearch__sysctl__dependent_parameters }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ elasticsearch__ferm__dependent_rules }}")))
      
        (role "java")
        (tags (list
            "role::java"
            "skip::java"))
      
        (role "elasticsearch")
        (tags (list
            "role::elasticsearch"
            "skip::elasticsearch")))))
