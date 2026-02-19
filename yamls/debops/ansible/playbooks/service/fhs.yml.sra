(playbook "debops/ansible/playbooks/service/fhs.yml"
    (play
    (name "Configure base directory hierarchy")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_fhs"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "fhs")
        (tags (list
            "role::fhs"
            "skip::fhs")))))
