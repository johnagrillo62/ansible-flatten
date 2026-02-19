(playbook "debops/ansible/playbooks/layer/systemd.yml"
  (tasks
    (task "Configure system and service manager"
      (import_playbook "../service/systemd.yml"))
    (task "Configure system journal and log service"
      (import_playbook "../service/journald.yml"))
    (task "Configure network manager service"
      (import_playbook "../service/networkd.yml"))
    (task "Configure time synchronization service"
      (import_playbook "../service/timesyncd.yml"))
    (task "Configure system resolver"
      (import_playbook "../service/resolved.yml"))))
