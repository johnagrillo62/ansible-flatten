(playbook "debops/ansible/playbooks/service/influxdb.yml"
    (play
    (name "Manage InfluxDB client")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_influxdb"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "python")
        (tags (list
            "role::python"
            "skip::python"
            "role::influxdb"))
        (python__dependent_packages3 (list
            (jinja "{{ influxdb__python__dependent_packages3 }}")))
        (python__dependent_packages2 (list
            (jinja "{{ influxdb__python__dependent_packages2 }}")))
      
        (role "influxdb")
        (tags (list
            "role::influxdb"
            "skip::influxdb")))))
