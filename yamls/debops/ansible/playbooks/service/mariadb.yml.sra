(playbook "debops/ansible/playbooks/service/mariadb.yml"
    (play
    (name "Manage MariaDB client")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_mariadb"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::mariadb"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ mariadb__keyring__dependent_apt_keys }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::mariadb"))
        (python__dependent_packages3 (list
            (jinja "{{ mariadb__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ mariadb__python__dependent_packages2 }}")))
      
        (role "mariadb")
        (tags (list
            "role::mariadb"
            "skip::mariadb")))))
