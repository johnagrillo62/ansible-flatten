(playbook "tools/docker-compose/ansible/roles/migrate/tasks/main.yml"
  (tasks
    (task
      (import_tasks "migrate-from-local-docker.yml")
      (when "migrate_local_docker"))))
