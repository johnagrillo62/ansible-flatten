(playbook "debops/ansible/debops-contrib-playbooks/service/kodi.yml"
    (play
    (name "Setup and manage Kodi")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_kodi"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "kodi")
        (tags (list
            "role::kodi")))))
