(playbook "debops/ansible/playbooks/service/avahi.yml"
    (play
    (name "Manage Avahi service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_avahi"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::avahi"))
        (python__dependent_packages3 (list
            (jinja "{{ avahi__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ avahi__python__dependent_packages2 }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ avahi__ferm__dependent_rules }}")))
      
        (role "avahi")
        (tags (list
            "role::avahi"
            "skip::avahi"))
      
        (role "nsswitch")
        (tags (list
            "role::nsswitch"
            "skip::nsswitch")))))
