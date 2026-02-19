(playbook "debops/ansible/playbooks/service/docker_gen.yml"
    (play
    (name "Manage docker-gen service")
    (collections (list
        "debops.debops"
        "debops.roles01"
        "debops.roles02"
        "debops.roles03"))
    (hosts (list
        "debops_service_docker_gen"))
    (become "True")
    (environment (jinja "{{ inventory__environment | d({})
                   | combine(inventory__group_environment | d({}))
                   | combine(inventory__host_environment  | d({})) }}"))
    (roles
      
        (role "docker_gen")
        (tags (list
            "role::docker_gen"
            "skip::docker_gen")))))
