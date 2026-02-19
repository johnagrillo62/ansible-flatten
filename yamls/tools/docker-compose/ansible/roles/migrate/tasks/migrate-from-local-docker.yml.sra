(playbook "tools/docker-compose/ansible/roles/migrate/tasks/migrate-from-local-docker.yml"
  (tasks
    (task "Remove awx_postgres to ensure consistent start state"
      (shell "docker rm -f awx_postgres
")
      (ignore_errors "true"))
    (task "Start Local Docker database container"
      (docker_compose 
        (project_src (jinja "{{ old_docker_compose_dir }}"))
        (services (list
            "postgres"))
        (state "present")
        (recreate "always")))
    (task "Wait for postgres to initialize"
      (wait_for 
        (timeout "3")))
    (task "Database dump to local filesystem"
      (shell "docker-compose -f " (jinja "{{ old_docker_compose_dir }}") "/docker-compose.yml exec -T postgres pg_dumpall -U " (jinja "{{ pg_username }}") " > awx_dump.sql
"))
    (task "Stop AWX containers so the old postgres container does not get used"
      (docker_compose 
        (project_src (jinja "{{ old_docker_compose_dir }}"))
        (state "absent"))
      (ignore_errors "true"))
    (task "Start dev env database container"
      (docker_compose 
        (project_src (jinja "{{ playbook_dir }}") "/../_sources")
        (files "docker-compose.yml")
        (services (list
            "postgres"))
        (state "present")
        (recreate "always"))
      (environment 
        (COMPOSE_PROJECT_NAME "tools")))
    (task "Wait for postgres to initialize"
      (wait_for 
        (timeout "3")))
    (task "Restore to new postgres container"
      (shell "COMPOSE_PROJECT_NAME=tools docker-compose -f " (jinja "{{ playbook_dir }}") "/../_sources/docker-compose.yml exec -T postgres psql -U " (jinja "{{ pg_username }}") " -d " (jinja "{{ pg_database }}") " -p " (jinja "{{ pg_port }}") " < awx_dump.sql
"))
    (task "Clean up temporary awx db dump"
      (file 
        (path "awx_dump.sql")
        (state "absent")))))
