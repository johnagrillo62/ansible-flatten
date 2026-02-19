(playbook "debops/ansible/debops-contrib-playbooks/service/homeassistant.yml"
  (tasks
    (task "Setup HomeAssistant as standalone"
      (import_playbook "homeassistant-plain.yml"))
    (task "Setup HomeAssistant behind nginx"
      (import_playbook "homeassistant-nginx.yml"))))
