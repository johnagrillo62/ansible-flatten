(playbook "debops/ansible/playbooks/service/pdns.yml"
  (tasks
    (task "Manage regular PowerDNS server installation"
      (import_playbook "pdns-plain.yml"))
    (task "Manage PowerDNS server installation with nginx frontend"
      (import_playbook "pdns-nginx.yml"))))
