(playbook "debops/ansible/playbooks/service/owncloud.yml"
  (tasks
    (task "Manage ownCloud/Nextcloud with Apache frontend"
      (import_playbook "owncloud-apache.yml"))
    (task "Manage ownCloud/Nextcloud with nginx frontend"
      (import_playbook "owncloud-nginx.yml"))))
