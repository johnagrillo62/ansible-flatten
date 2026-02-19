(playbook "debops/ansible/playbooks/service/timesyncd.yml"
    (play
    (name "Manage systemd-timesyncd service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_timesyncd"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "timesyncd")
        (tags (list
            "role::timesyncd"
            "skip::timesyncd")))))
