(playbook "debops/ansible/playbooks/service/libvirtd_qemu.yml"
    (play
    (name "Install and manage libvirtd QEMU configuration")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_libvirtd_qemu"))
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
            (jinja "{{ libvirtd_qemu__ferm__dependent_rules }}")))
      
        (role "libvirtd_qemu")
        (tags (list
            "role::libvirtd_qemu"
            "skip::libvirtd_qemu")))))
