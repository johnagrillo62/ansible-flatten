(playbook "kubespray/scale.yml"
  (tasks
    (task "Scale the cluster"
      (ansible.builtin.import_playbook "playbooks/scale.yml"))))
