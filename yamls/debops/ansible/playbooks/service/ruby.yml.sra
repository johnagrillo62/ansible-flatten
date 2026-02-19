(playbook "debops/ansible/playbooks/service/ruby.yml"
    (play
    (name "Manage Ruby environment")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_ruby"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "ruby")
        (tags (list
            "role::ruby"
            "skip::ruby")))))
