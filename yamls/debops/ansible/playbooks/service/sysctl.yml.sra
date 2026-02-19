(playbook "debops/ansible/playbooks/service/sysctl.yml"
    (play
    (name "Manage kernel parameters using sysctl")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_sysctl"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "sysctl")
        (tags (list
            "role::sysctl"
            "skip::sysctl")))))
