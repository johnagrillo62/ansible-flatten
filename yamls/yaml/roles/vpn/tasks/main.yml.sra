(playbook "yaml/roles/vpn/tasks/main.yml"
  (tasks
    (task
      (import_tasks "openvpn.yml")
      (tags "openvpn"))))
