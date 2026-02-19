(playbook "debops/ansible/playbooks/service/proc_hidepid.yml"
    (play
    (name "Manage /proc hidepid= configuration")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_proc_hidepid"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "proc_hidepid")
        (tags (list
            "role::proc_hidepid"
            "skip::proc_hidepid")))))
