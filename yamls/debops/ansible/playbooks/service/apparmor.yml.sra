(playbook "debops/ansible/playbooks/service/apparmor.yml"
    (play
    (name "Install and configure AppArmor")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_apparmor"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "apparmor")
        (tags (list
            "role::apparmor"
            "skip::apparmor")))))
