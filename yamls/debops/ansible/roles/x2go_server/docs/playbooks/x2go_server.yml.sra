(playbook "debops/ansible/roles/x2go_server/docs/playbooks/x2go_server.yml"
    (play
    (name "Setup and manage the server-side of X2Go")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_x2go_server"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "x2go_server")
        (tags (list
            "role::x2go_server")))))
