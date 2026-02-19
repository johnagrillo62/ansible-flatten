(playbook "debops/ansible/playbooks/service/ipxe.yml"
    (play
    (name "Manage iPXE configuration files")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_ipxe"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "ipxe")
        (tags (list
            "role::ipxe"
            "skip::ipxe")))))
