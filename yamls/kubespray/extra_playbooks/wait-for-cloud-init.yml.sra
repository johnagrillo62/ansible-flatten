(playbook "kubespray/extra_playbooks/wait-for-cloud-init.yml"
    (play
    (name "Wait for cloud-init to finish")
    (hosts "all")
    (tasks
      (task "Wait for cloud-init to finish"
        (command "cloud-init status --wait")))))
