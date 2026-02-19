(playbook "debops/ansible/playbooks/service/dropbear_initramfs.yml"
    (play
    (name "Setup the dropbear ssh server in initramfs")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_dropbear_initramfs"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "dropbear_initramfs")
        (tags (list
            "role::dropbear_initramfs"
            "skip::dropbear_initramfs")))))
