(playbook "debops/ansible/playbooks/service/snmpd.yml"
    (play
    (name "Manage SNMP service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_snmpd"))
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
            (jinja "{{ snmpd_ferm_dependent_rules }}")))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers_dependent_allow (list
            (jinja "{{ snmpd_tcpwrappers_dependent_allow }}")))
      
        (role "snmpd")
        (tags (list
            "role::snmpd"
            "skip::snmpd"))
      
        (role "lldpd")
        (tags (list
            "role::lldpd"
            "skip::lldpd")))))
