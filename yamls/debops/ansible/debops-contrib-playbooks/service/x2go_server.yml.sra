(playbook "debops/ansible/debops-contrib-playbooks/service/x2go_server.yml"
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
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::x2go_server"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ x2go_server__keyring__dependent_apt_keys }}")))
      
        (role "x2go_server")
        (tags (list
            "role::x2go_server")))))
