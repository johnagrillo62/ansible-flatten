(playbook "debops/ansible/playbooks/service/influxdb_server.yml"
    (play
    (name "Manage InfluxDB server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_influxdb_server"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::influxdata"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ influxdata__keyring__dependent_apt_keys }}")))
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"))
        (etc_services__dependent_list (list
            (jinja "{{ influxdb_server__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ influxdb_server__ferm__dependent_rules }}")))
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::influxdb_server"))
        (python__dependent_packages3 (list
            (jinja "{{ influxdb_server__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ influxdb_server__python__dependent_packages2 }}")))
      
        (role "influxdata")
        (tags (list
            "role::influxdata"
            "skip::influxdata"))
        (influxdata__dependent_packages (list
            (jinja "{{ influxdb_server__influxdata__dependent_packages }}")))
      
        (role "influxdb_server")
        (tags (list
            "role::influxdb_server"
            "skip::influxdb_server")))))
