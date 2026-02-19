(playbook "debops/ansible/playbooks/service/influxdata.yml"
    (play
    (name "Manage InfluxData APT repositories")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_influxdata"))
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
      
        (role "influxdata")
        (tags (list
            "role::influxdata"
            "skip::influxdata")))))
