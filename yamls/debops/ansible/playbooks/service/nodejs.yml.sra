(playbook "debops/ansible/playbooks/service/nodejs.yml"
    (play
    (name "Manage NodeJS environment")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_nodejs"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::nodejs"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ nodejs__keyring__dependent_apt_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nodejs__apt_preferences__dependent_list }}")))
      
        (role "nodejs")
        (tags (list
            "role::nodejs"
            "skip::nodejs")))))
