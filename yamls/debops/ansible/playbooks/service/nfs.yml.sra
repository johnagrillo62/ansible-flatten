(playbook "debops/ansible/playbooks/service/nfs.yml"
    (play
    (name "Manage NFS shares")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_nfs"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "nfs")
        (tags (list
            "role::nfs"
            "skip::nfs")))))
