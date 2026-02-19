(playbook "openshift-ansible/hack/libvirt/playbooks/prep.yml"
    (play
    (hosts "nodes")
    (tasks
      (task
        (command "dnf -y update"))
      (task
        (command "dnf install NetworkManager -y"))
      (task "Start NetworkManager"
        (command "systemctl start NetworkManager"))
      (task "Enable NetworkManager"
        (command "systemctl enable NetworkManager"))
      (task "Install docker"
        (command "dnf install docker -y"))
      (task "Start Docker"
        (command "systemctl start docker"))
      (task "Enable docker"
        (command "systemctl enable docker")))))
