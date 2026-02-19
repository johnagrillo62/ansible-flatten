(playbook "debops/ansible/playbooks/service/nfs_server.yml"
    (play
    (name "Configure NFS Server")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_nfs_server"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "etc_services")
        (tags (list
            "role::etc_services"
            "skip::etc_services"
            "role::ferm"))
        (etc_services__dependent_list (list
            (jinja "{{ nfs_server__etc_services__dependent_list }}")))
      
        (role "ferm")
        (tags (list
            "role::ferm"
            "skip::ferm"))
        (ferm__dependent_rules (list
            (jinja "{{ nfs_server__ferm__dependent_rules }}")))
      
        (role "tcpwrappers")
        (tags (list
            "role::tcpwrappers"
            "skip::tcpwrappers"))
        (tcpwrappers__dependent_allow (list
            (jinja "{{ nfs_server__tcpwrappers__dependent_allow }}")))
      
        (role "nfs_server")
        (tags (list
            "role::nfs_server"
            "skip::nfs_server")))))
