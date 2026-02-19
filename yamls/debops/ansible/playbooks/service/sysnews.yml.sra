(playbook "debops/ansible/playbooks/service/sysnews.yml"
    (play
    (name "Manage System News entries")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_sysnews"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "sysnews")
        (tags (list
            "role::sysnews"
            "skip::sysnews")))))
