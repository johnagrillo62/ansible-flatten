(playbook "debops/ansible/playbooks/reboot.yml"
    (play
    (name "Reboot DebOps hosts")
    (hosts (list
        "debops_all_hosts"))
    (become "True")
    (gather_facts "False")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "reboot")
        (tags (list
            "role::reboot"
            "skip::reboot")))))
