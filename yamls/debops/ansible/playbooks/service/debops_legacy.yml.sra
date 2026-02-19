(playbook "debops/ansible/playbooks/service/debops_legacy.yml"
    (play
    (name "Clean up legacy configuration")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "debops_legacy")
        (tags (list
            "role::debops_legacy"
            "skip::debops_legacy")))))
