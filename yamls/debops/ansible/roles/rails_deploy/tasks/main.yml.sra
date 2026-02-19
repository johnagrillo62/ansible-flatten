(playbook "debops/ansible/roles/rails_deploy/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Configure system environment"
      (ansible.builtin.include_tasks "system.yml")
      (tags "rails_deploy"))
    (task "Configure database"
      (ansible.builtin.include_tasks "database.yml")
      (when "rails_deploy_database_create")
      (tags "rails_deploy_setup"))
    (task "Deploy access keys"
      (ansible.builtin.include_tasks "deploy_keys.yml")
      (tags "rails_deploy_setup"))
    (task "Deploy application"
      (ansible.builtin.include_tasks "deploy.yml")
      (tags "rails_deploy"))
    (task "Configure local facts"
      (ansible.builtin.include_tasks "local_facts.yml")
      (tags "rails_deploy"))))
