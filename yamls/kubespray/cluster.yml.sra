(playbook "kubespray/cluster.yml"
  (tasks
    (task "Install Kubernetes"
      (ansible.builtin.import_playbook "playbooks/cluster.yml"))))
