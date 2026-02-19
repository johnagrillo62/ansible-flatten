(playbook "debops/docs/ansible/roles/console/playbooks/console.yml"
    (play
    (name "Manage console configuration")
    (collections (list
        "debops.debops"))
    (hosts (list
        "debops_all_hosts"
        "debops_service_console"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "console")
        (tags (list
            "role::console")))))
