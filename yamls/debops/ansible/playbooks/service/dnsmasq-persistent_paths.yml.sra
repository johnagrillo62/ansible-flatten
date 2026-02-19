(playbook "debops/ansible/playbooks/service/dnsmasq-persistent_paths.yml"
    (play
    (name "Configure dnsmasq and ensure persistence")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_dnsmasq_persistent_paths"))
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
      
        (role "resolvconf")
        (tags (list
            "role::resolvconf"
            "skip::resolvconf"))
        (resolvconf__dependent_services (list
            "dnsmasq"))
      
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
      
        (role "dnsmasq")
        (tags (list
            "role::dnsmasq"
            "skip::dnsmasq"))
      
        (role "persistent_paths")
        (tags (list
            "role::persistent_paths"
            "skip::persistent_paths"))
        (persistent_paths__dependent_paths (jinja "{{ dnsmasq__persistent_paths__dependent_paths }}")))))
