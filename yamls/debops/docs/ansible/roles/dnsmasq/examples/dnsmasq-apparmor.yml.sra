(playbook "debops/docs/ansible/roles/dnsmasq/examples/dnsmasq-apparmor.yml"
    (play
    (name "Configure AppArmor for dnsmasq")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_contrib_service_dnsmasq"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (pre_tasks
      (task "Prepare dnsmasq environment"
        (ansible.builtin.import_role 
          (name "dnsmasq")
          (tasks_from "main_env"))
        (tags (list
            "role::dnsmasq"
            "role::ferm"
            "role::tcpwrappers"))))
    (roles
      
        (role "apparmor")
        (tags (list
            "role::apparmor"))
        (apparmor__local_dependent_config (jinja "{{ dnsmasq__apparmor__local_dependent_config }}"))))
    (play
    (name "Configure dnsmasq")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_contrib_service_dnsmasq"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ dnsmasq__ferm__dependent_rules }}")))
      
        (role "dnsmasq")
        (tags (list
            "role::dnsmasq")))))
