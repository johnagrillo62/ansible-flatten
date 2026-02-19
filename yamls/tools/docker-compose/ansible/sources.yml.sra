(playbook "tools/docker-compose/ansible/sources.yml"
    (play
    (name "Render AWX Dockerfile and sources")
    (hosts "localhost")
    (gather_facts "true")
    (roles
      
        (role "sources"))))
