(playbook "debops/ansible/playbooks/service/java.yml"
    (play
    (name "Manage Java environment")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_java"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "java")
        (tags (list
            "role::java"
            "skip::java")))))
