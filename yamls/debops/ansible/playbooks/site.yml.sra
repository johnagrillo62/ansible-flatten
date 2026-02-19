(playbook "debops/ansible/playbooks/site.yml"
  (tasks
    (task "Manage network layer"
      (import_playbook "layer/net.yml"))
    (task "Manage system service layer"
      (import_playbook "layer/sys.yml"))
    (task "Manage services common on all hosts"
      (import_playbook "layer/common.yml"))
    (task "Manage programming language environments"
      (import_playbook "layer/env.yml"))
    (task "Manage userspace service layer"
      (import_playbook "layer/srv.yml"))
    (task "Manage userspace applications"
      (import_playbook "layer/app.yml"))
    (task "Manage virtual machine layer"
      (import_playbook "layer/virt.yml"))
    (task "Manage hardware layer"
      (import_playbook "layer/hw.yml"))
    (task "Manage service agents"
      (import_playbook "layer/agent.yml"))))
