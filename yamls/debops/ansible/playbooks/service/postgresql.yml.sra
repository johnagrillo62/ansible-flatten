(playbook "debops/ansible/playbooks/service/postgresql.yml"
    (play
    (name "Manage PostgreSQL client")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_postgresql"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::postgresql"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ postgresql__keyring__dependent_apt_keys }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::postgresql"))
        (python__dependent_packages3 (list
            (jinja "{{ postgresql__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ postgresql__python__dependent_packages2 }}")))
      
        (role "postgresql")
        (tags (list
            "role::postgresql"
            "skip::postgresql")))))
