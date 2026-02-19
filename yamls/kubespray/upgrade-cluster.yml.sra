(playbook "kubespray/upgrade-cluster.yml"
  (tasks
    (task "Upgrade cluster"
      (ansible.builtin.import_playbook "playbooks/upgrade_cluster.yml"))))
