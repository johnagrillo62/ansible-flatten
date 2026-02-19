(playbook "debops/ansible/playbooks/service/libvirtd.yml"
    (play
    (name "Install and manage libvirtd")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_libvirtd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "nsswitch")
        (tags (list
            "role::nsswitch"
            "skip::nsswitch"))
        (nsswitch__dependent_services (list
            (jinja "{{ libvirtd__nsswitch__dependent_services }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ libvirtd__ferm__dependent_rules }}")
            (jinja "{{ libvirtd_qemu__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ libvirtd__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ libvirtd__python__dependent_packages2 }}")))
      
        (role "libvirtd")
        (tags (list
            "role::libvirtd"
            "skip::libvirtd"))
      
        (role "libvirtd_qemu")
        (tags (list
            "role::libvirtd_qemu"
            "skip::libvirtd_qemu"
            "role::libvirtd"
            "skip::libvirtd")))))
