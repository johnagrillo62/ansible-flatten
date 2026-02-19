(playbook "debops/ansible/debops-contrib-playbooks/service/foodsoft.yml"
  (tasks
    (task "Install and configure Foodsoft"
      (import_playbook "foodsoft-nginx.yml"))))
