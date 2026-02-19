(playbook "openshift-ansible/hack/libvirt/playbooks/rhel_prep.yml"
    (play
    (hosts "nodes")
    (tasks
      (task
        (command "yum -y update"))
      (task
        (command "yum install NetworkManager -y"))
      (task "Start NetworkManager"
        (command "systemctl start NetworkManager"))
      (task "Enable NetworkManager"
        (command "systemctl enable NetworkManager")))))
