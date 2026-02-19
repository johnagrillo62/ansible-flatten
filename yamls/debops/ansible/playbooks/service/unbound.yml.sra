(playbook "debops/ansible/playbooks/service/unbound.yml"
    (play
    (name "Manage Unbound, local DNS resolver")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_unbound"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "resolvconf")
        (tags (list
            "role::resolvconf"
            "skip::resolvconf"))
        (resolvconf__dependent_services (list
            "unbound"))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ unbound__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ unbound__python__dependent_packages2 }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ unbound__etc_services__dependent_list }}")))
      
        (role "unbound")
        (tags (list
            "role::unbound"
            "skip::unbound")))))
