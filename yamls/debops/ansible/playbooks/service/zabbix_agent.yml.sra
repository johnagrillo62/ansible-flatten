(playbook "debops/ansible/playbooks/service/zabbix_agent.yml"
    (play
    (name "Install and manage Zabbix agent")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_zabbix_agent"))
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
            (jinja "{{ zabbix_agent__ferm__dependent_rules }}")))
      
        (role "zabbix_agent")
        (tags (list
            "role::zabbix_agent"
            "skip::zabbix_agent")))))
