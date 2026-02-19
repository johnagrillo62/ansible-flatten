(playbook "debops/ansible/playbooks/service/cryptsetup-plain.yml"
    (play
    (name "Setup and manage encrypted filesystems")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_cryptsetup"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "cryptsetup")
        (tags (list
            "role::cryptsetup"
            "skip::cryptsetup")))))
