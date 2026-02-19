(playbook "debops/ansible/playbooks/service/cryptsetup.yml"
  (tasks
    (task "Manage regular cryptsetup installation"
      (import_playbook "cryptsetup-plain.yml"))
    (task "Manage cryptsetup on QbesOS"
      (import_playbook "cryptsetup-persistent_paths.yml"))))
