(playbook "debops/ansible/playbooks/service/tcpwrappers.yml"
    (play
    (name "Manage TCP Wrappers")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_tcpwrappers"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers")))))
