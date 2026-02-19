(playbook "debops/ansible/playbooks/service/dnsmasq.yml"
  (tasks
    (task "Manage regular dnsmasq installation"
      (import_playbook "dnsmasq-plain.yml"))
    (task "Manage dnsmasq installation on QbesOS"
      (import_playbook "dnsmasq-persistent_paths.yml"))))
