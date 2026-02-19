(playbook "debops/ansible/debops-contrib-playbooks/service/homeassistant-plain.yml"
    (play
    (name "Setup and manage Home Assistant")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_homeassistant"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "homeassistant")
        (tags (list
            "role::homeassistant")))))
