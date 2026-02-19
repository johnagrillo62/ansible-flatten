(playbook "debops/ansible/playbooks/service/core.yml"
    (play
    (name "Prepare core environment")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_core"
        "debops_service_bootstrap"))
    (become "False")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "core")
        (tags (list
            "role::core"
            "skip::core"))
        (become "True"))))
