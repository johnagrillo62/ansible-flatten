(playbook "debops/ansible/playbooks/service/nsswitch.yml"
    (play
    (name "Manage Name Service Switch configuration")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_nsswitch"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "nsswitch")
        (tags (list
            "role::nsswitch"
            "skip::nsswitch")))))
