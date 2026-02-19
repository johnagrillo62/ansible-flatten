(playbook "debops/ansible/playbooks/service/iscsi.yml"
    (play
    (name "Configure iSCSI Initiator")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_iscsi"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "unattended_upgrades")
        (tags (list
            "role::unattended_upgrades"
            "skip::unattended_upgrades"))
        (unattended_upgrades__dependent_blacklist (jinja "{{ iscsi__unattended_upgrades__dependent_blacklist }}"))
      
        (role "lvm")
        (tags (list
            "role::lvm"
            "skip::lvm"))
      
        (role "iscsi")
        (tags (list
            "role::iscsi"
            "skip::iscsi")))))
