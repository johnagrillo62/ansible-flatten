(playbook "debops/docs/ansible/roles/foodsoft/playbooks/foodsoft.yml"
  (tasks
    (task "Manage Foodsoft with nginx frontend"
      (import_playbook "foodsoft-nginx.yml"))))
