(playbook "debops/ansible/playbooks/service/monit.yml"
    (play
    (name "Manage Monit service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_monit"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "monit")
        (tags (list
            "role::monit"
            "skip::monit")))))
