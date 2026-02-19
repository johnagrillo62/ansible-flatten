(playbook "debops/ansible/playbooks/service/apt_install.yml"
    (play
    (name "Install APT packages")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_apt_install"))
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
            (jinja "{{ apt_install__apt_preferences__dependent_list }}")))
      
        (role "apt_install")
        (tags (list
            "role::apt_install"
            "skip::apt_install")))))
