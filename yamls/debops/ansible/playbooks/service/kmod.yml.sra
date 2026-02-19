(playbook "debops/ansible/playbooks/service/kmod.yml"
    (play
    (name "Manage kernel modules")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_kmod"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::kmod"))
        (python__dependent_packages3 (list
            (jinja "{{ kmod__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ kmod__python__dependent_packages2 }}")))
      
        (role "kmod")
        (tags (list
            "role::kmod"
            "skip::kmod")))))
