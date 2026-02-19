(playbook "debops/ansible/playbooks/service/debops_fact.yml"
    (play
    (name "Manage Ansible local facts for other roles")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_debops_fact"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "debops_fact")
        (tags (list
            "role::debops_fact"
            "skip::debops_fact")))))
