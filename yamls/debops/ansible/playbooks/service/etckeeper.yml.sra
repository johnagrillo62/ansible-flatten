(playbook "debops/ansible/playbooks/service/etckeeper.yml"
    (play
    (name "Put /etc under version control using etckeeper")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_etckeeper"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ etckeeper__apt_preferences__dependent_list }}")))
      
        (role "etckeeper")
        (tags (list
            "role::etckeeper"
            "skip::etckeeper")))))
