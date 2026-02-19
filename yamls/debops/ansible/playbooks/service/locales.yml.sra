(playbook "debops/ansible/playbooks/service/locales.yml"
    (play
    (name "Configure localization and internationalization")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_locales"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "locales")
        (tags (list
            "role::locales"
            "skip::locales")))))
