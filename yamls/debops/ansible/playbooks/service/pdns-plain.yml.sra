(playbook "debops/ansible/playbooks/service/pdns-plain.yml"
    (play
    (name "Manage PowerDNS authoritative server")
    (hosts (list
        "debops_service_pdns"))
    (become "True")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ pdns__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ pdns__ferm__dependent_rules }}")))
      
        (role "postgresql")
        (tags (list
            "role::postgresql"
            "skip::postgresql"))
        (postgresql__dependent_roles (list
            (jinja "{{ pdns__postgresql__dependent_roles }}")))
      
        (role "pdns")
        (tags (list
            "role::pdns"
            "skip::pdns")))))
