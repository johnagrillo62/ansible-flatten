(playbook "debops/ansible/playbooks/service/libvirt.yml"
    (play
    (name "Manage libvirt hosts")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_libvirt"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ libvirt__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ libvirt__python__dependent_packages2 }}")))
      
        (role "libvirt")
        (tags (list
            "role::libvirt"
            "skip::libvirt")))))
