(playbook "debops/ansible/playbooks/service/tinc.yml"
  (tasks
    (task "Manage regular Tinc VPN installation"
      (import_playbook "tinc-plain.yml"))
    (task "Manage Tinc VPN installation on QubesOS"
      (import_playbook "tinc-persistent_paths.yml"))))
