(playbook "debops/ansible/playbooks/service/journald.yml"
    (play
    (name "Manage systemd journal service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_journald"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "journald")
        (tags (list
            "role::journald"
            "skip::journald")))))
