(playbook "debops/ansible/playbooks/service/hwraid.yml"
    (play
    (name "Configure HWRaid support")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_hwraid"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "keyring")
        (tags (list
            "role::keyring"
            "skip::keyring"
            "role::hwraid"))
        (keyring__dependent_apt_keys (list
            (jinja "{{ hwraid__keyring__dependent_apt_keys }}")))
      
        (role "hwraid")
        (tags (list
            "role::hwraid"
            "skip::hwraid")))))
