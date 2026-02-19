(playbook "debops/ansible/playbooks/service/networkd.yml"
    (play
    (name "Manage systemd-networkd service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_networkd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "networkd")
        (tags (list
            "role::networkd"
            "skip::networkd")))))
