(playbook "debops/ansible/playbooks/service/debconf.yml"
    (play
    (name "Manage debconf-based services")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_debconf"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "debconf")
        (tags (list
            "role::debconf"
            "skip::debconf")))))
