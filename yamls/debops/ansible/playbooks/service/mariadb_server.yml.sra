(playbook "debops/ansible/playbooks/service/mariadb_server.yml"
    (play
    (name "Manage MariaDB server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_mariadb_server"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::mariadb_server"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ mariadb_server__keyring__dependent_apt_keys }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ mariadb_server__etc_services__dependent_rules }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ mariadb_server__ferm__dependent_rules }}")))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers__dependent_allow (list
            (jinja "{{ mariadb_server__tcpwrappers__dependent_allow }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::mariadb_server"))
        (python__dependent_packages3 (list
            (jinja "{{ mariadb_server__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ mariadb_server__python__dependent_packages2 }}")))
      
        (role "mariadb_server")
        (tags (list
            "role::mariadb_server"
            "skip::mariadb_server")))))
