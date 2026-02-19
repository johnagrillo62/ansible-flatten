(playbook "debops/ansible/playbooks/service/authorized_keys.yml"
    (play
    (name "Manage SSH public keys")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_authorized_keys"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "authorized_keys")
        (tags (list
            "role::authorized_keys"
            "skip::authorized_keys")))))
