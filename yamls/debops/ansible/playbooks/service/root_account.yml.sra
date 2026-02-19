(playbook "debops/ansible/playbooks/service/root_account.yml"
    (play
    (name "Manage root system account")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_root_account"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "root_account")
        (tags (list
            "role::root_account"
            "skip::root_account")))))
