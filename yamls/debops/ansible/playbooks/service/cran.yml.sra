(playbook "debops/ansible/playbooks/service/cran.yml"
    (play
    (name "Manage the Comprehensive R Archive Network packages")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_cran"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::cran"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ cran__keyring__dependent_apt_keys }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ cran__apt_preferences__dependent_list }}")))
      
        (role "java")
        (tags (list
            "role::java"
            "skip::java"))
        (java__install_jdk "True")
        (when "cran__java_integration | bool")
      
        (role "cran")
        (tags (list
            "role::cran"
            "skip::cran")))))
