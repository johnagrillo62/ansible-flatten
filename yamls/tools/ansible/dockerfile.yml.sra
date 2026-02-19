(playbook "tools/ansible/dockerfile.yml"
    (play
    (name "Render AWX Dockerfile and sources")
    (hosts "localhost")
    (gather_facts "true")
    (roles
      
        (role "dockerfile"))))
