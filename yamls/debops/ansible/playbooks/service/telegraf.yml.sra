(playbook "debops/ansible/playbooks/service/telegraf.yml"
    (play
    (name "Manage Telegraf instance")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_telegraf"))
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
            "skip::influxdata"))
        (influxdata__dependent_packages (list
            (jinja "{{ telegraf__influxdata__dependent_packages }}")))
      
        (role "telegraf")
        (tags (list
            "role::telegraf"
            "skip::telegraf")))))
