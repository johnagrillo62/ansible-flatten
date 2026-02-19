(playbook "debops/ansible/playbooks/service/yadm.yml"
    (play
    (name "Configure yadm, Yet Another Dotfiles Manager")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_yadm"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::yadm"))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ yadm__keyring__dependent_gpg_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ yadm__apt_preferences__dependent_list }}")))
      
        (role "yadm")
        (tags (list
            "role::yadm"
            "skip::yadm")))))
