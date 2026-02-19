(playbook "debops/ansible/playbooks/service/rstudio_server.yml"
    (play
    (name "Manage RStudio Server service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_rstudio_server"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::cran"
            "role::nginx"
            "role::rstudio_server"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ cran__keyring__dependent_apt_keys | d([]) }}")
            (jinja "{{ nginx__keyring__dependent_apt_keys | d([]) }}")))
        (keyring__dependent_gpg_keys (list
            (jinja "{{ rstudio_server__keyring__dependent_gpg_keys | d([]) }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ rstudio_server__etc_services__dependent_list }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ nginx__apt_preferences__dependent_list }}")
            (jinja "{{ cran__apt_preferences__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nginx__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ nginx__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ nginx__python__dependent_packages2 }}")))
      
        (role "nginx")
        (tags (list
            "role::nginx"
            "skip::nginx"))
        (nginx__dependent_servers (list
            (jinja "{{ rstudio_server__nginx__dependent_servers }}")))
      
        (role "java")
        (tags (list
            "role::java"
            "skip::java"))
        (java__install_jdk "True")
        (when "cran__java_integration | bool")
      
        (role "cran")
        (tags (list
            "role::cran"
            "skip::cran"))
        (cran__dependent_packages (list
            (jinja "{{ rstudio_server__cran__dependent_packages }}")))
      
        (role "rstudio_server")
        (tags (list
            "role::rstudio_server"
            "skip::rstudio_server")))))
