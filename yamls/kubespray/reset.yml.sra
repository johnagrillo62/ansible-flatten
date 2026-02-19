(playbook "kubespray/reset.yml"
  (tasks
    (task "Reset the cluster"
      (ansible.builtin.import_playbook "playbooks/reset.yml"))))
