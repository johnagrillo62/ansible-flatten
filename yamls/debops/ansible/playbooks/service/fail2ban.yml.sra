(playbook "debops/ansible/playbooks/service/fail2ban.yml"
    (play
    (name "Manage fail2ban service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_fail2ban"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "fail2ban")
        (tags (list
            "role::fail2ban"
            "skip::fail2ban")))))
