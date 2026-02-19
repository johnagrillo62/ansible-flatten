(playbook "debops/ansible/playbooks/service/ansible.yml"
    (play
    (name "Install and configure Ansible")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_ansible"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::ansible"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ ansible__keyring__dependent_apt_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ ansible__apt_preferences__dependent_list }}")))
      
        (role "ansible")
        (tags (list
            "role::ansible"
            "skip::ansible")))))
