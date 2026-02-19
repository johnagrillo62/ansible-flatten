(playbook "debops/ansible/playbooks/service/salt.yml"
    (play
    (name "Manage Salt Master service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_salt"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::salt"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ salt__keyring__dependent_apt_keys }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ salt__etc_services__dependent_list }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"))
        (python__dependent_packages3 (list
            (jinja "{{ salt__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ salt__python__dependent_packages2 }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ salt__ferm__dependent_rules }}")))
      
        (role "salt")
        (tags (list
            "role::salt"
            "skip::salt")))))
