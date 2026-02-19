(playbook "debops/ansible/playbooks/service/apache.yml"
    (play
    (name "Manage and configure the Apache HTTP Server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_apache"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare apache environment"
        (ansible.builtin.import_role 
          (name "apache")
          (tasks_from "main_env"))
        (tags (list
            "role::apache"
            "role::apache:env"))))
    (roles
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ apache__ferm__dependent_rules }}")))
      
        (role "apache")
        (tags (list
            "role::apache"
            "skip::apache")))))
