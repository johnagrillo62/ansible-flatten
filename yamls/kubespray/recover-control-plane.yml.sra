(playbook "kubespray/recover-control-plane.yml"
  (tasks
    (task "Recover control plane"
      (ansible.builtin.import_playbook "playbooks/recover_control_plane.yml"))))
