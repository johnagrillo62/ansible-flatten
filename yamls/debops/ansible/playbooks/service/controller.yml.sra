(playbook "debops/ansible/playbooks/service/controller.yml"
    (play
    (name "Prepare host to be used as Ansible Controller")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_controller"))
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
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::controller"))
        (python__dependent_packages3 (list
            (jinja "{{ controller__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ controller__python__dependent_packages2 }}")))
      
        (role "ansible")
        (tags (list
            "role::ansible"
            "skip::ansible"))
      
        (role "controller")
        (tags (list
            "role::controller"
            "skip::controller")))))
