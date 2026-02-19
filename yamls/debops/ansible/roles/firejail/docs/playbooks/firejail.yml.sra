(playbook "debops/ansible/roles/firejail/docs/playbooks/firejail.yml"
    (play
    (name "Setup and configure Firejail")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_firejail"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "secret")
      
        (role "firejail")
        (tags (list
            "role::firejail")))))
