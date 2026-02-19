(playbook "debops/ansible/debops-contrib-playbooks/service/dnsmasq.yml"
    (play
    (name "Configure dnsmasq")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
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
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ dnsmasq__ferm__dependent_rules }}")))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers__dependent_allow (list
            (jinja "{{ dnsmasq__env_tcpwrappers__dependent_allow }}")))
      
        (role "apparmor")
        (tags (list
            "role::apparmor"))
        (apparmor__local_dependent_config (jinja "{{ dnsmasq__apparmor__local_dependent_config }}"))
      
        (role "dnsmasq")
        (tags (list
            "role::dnsmasq"
            "skip::dnsmasq")))))
