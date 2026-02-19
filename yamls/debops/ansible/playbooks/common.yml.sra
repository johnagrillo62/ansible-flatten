(playbook "debops/ansible/playbooks/common.yml"
  (tasks
    (task "Apply common configuration on hosts"
      (import_playbook "layer/common.yml"))))
