(playbook "debops/ansible/roles/rails_deploy/tasks/local_facts.yml"
  (tasks
    (task "Create Ansible facts directory"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "rails_deploy_database_force_migrate or rails_deploy_git_location is defined and rails_deploy_git_location"))
    (task "Create local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/rails_deploy.fact.j2")
        (dest "/etc/ansible/facts.d/rails_deploy.fact")
        (mode "0644"))
      (when "rails_deploy_database_force_migrate or rails_deploy_git_location is defined and rails_deploy_git_location"))))
