(playbook "debops/ansible/playbooks/service/neurodebian.yml"
    (play
    (name "Install packages from the NeuroDebian repository")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_neurodebian"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ neurodebian__apt_preferences__dependent_list }}")))
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::neurodebian"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ neurodebian__keyring__dependent_apt_keys }}")))
      
        (role "neurodebian")
        (tags (list
            "role::neurodebian"
            "skip::neurodebian")))))
