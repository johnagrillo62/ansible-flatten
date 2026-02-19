(playbook "debops/ansible/debops-contrib-playbooks/service/fuse.yml"
    (play
    (name "Install and configure Filesystem in Userspace (FUSE)")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_fuse"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "fuse")
        (tags (list
            "role::fuse")))))
