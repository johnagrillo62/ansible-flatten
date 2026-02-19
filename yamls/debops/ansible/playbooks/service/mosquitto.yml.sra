(playbook "debops/ansible/playbooks/service/mosquitto.yml"
  (tasks
    (task "Manage regular Mosquitto installation"
      (import_playbook "mosquitto-plain.yml"))
    (task "Manage Mosquitto service with nginx frontend"
      (import_playbook "mosquitto-nginx.yml"))))
