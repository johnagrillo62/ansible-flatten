(playbook "debops/ansible/playbooks/service/unattended_upgrades.yml"
    (play
    (name "Manage unattended APT upgrades")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_unattended_upgrades"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "unattended_upgrades")
        (tags (list
            "role::unattended_upgrades"
            "skip::unattended_upgrades")))))
