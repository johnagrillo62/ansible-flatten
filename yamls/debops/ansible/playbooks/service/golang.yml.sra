(playbook "debops/ansible/playbooks/service/golang.yml"
    (play
    (name "Manage Go environment")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_golang"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::golang"))
        (keyring__dependent_gpg_user (jinja "{{ golang__keyring__dependent_gpg_user }}"))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ golang__keyring__dependent_gpg_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ golang__apt_preferences__dependent_list }}")))
      
        (role "golang")
        (tags (list
            "role::golang"
            "skip::golang")))))
