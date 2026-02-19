(playbook "debops/ansible/playbooks/service/gitlab.yml"
    (play
    (name "Manage GitLab Omnibus service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_gitlab"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ gitlab__keyring__dependent_apt_keys }}")))
      
        (role "extrepo")
        (tags (list
            "role::extrepo"
            "skip::extrepo"))
        (extrepo__dependent_sources (list
            (jinja "{{ gitlab__extrepo__dependent_sources }}")))
      
        (role "apt_preferences")
        (tags (list
            "role::apt_preferences"
            "skip::apt_preferences"))
        (apt_preferences__dependent_list (list
            (jinja "{{ gitlab__apt_preferences__dependent_list }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ gitlab__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ gitlab__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::ldap"))
        (python__dependent_packages3 (list
            (jinja "{{ ldap__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ ldap__python__dependent_packages2 }}")))
      
        (role "ldap")
        (tags (list
            "role::ldap"
            "skip::ldap"))
        (ldap__dependent_tasks (list
            (jinja "{{ gitlab__ldap__dependent_tasks }}")))
      
        (role "gitlab")
        (tags (list
            "role::gitlab"
            "skip::gitlab")))))
