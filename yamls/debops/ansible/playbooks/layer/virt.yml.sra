(playbook "debops/ansible/playbooks/layer/virt.yml"
  (tasks
    (task "Configure LXC service"
      (import_playbook "../service/lxc.yml"))
    (task "Configure LXD service"
      (import_playbook "../service/lxd.yml"))
    (task "Configure Docker Engine service"
      (import_playbook "../service/docker_server.yml"))
    (task "Configure libvirt daemon service"
      (import_playbook "../service/libvirtd.yml"))
    (task "Configure libvirt qemu support"
      (import_playbook "../service/libvirtd_qemu.yml"))
    (task "Configure libvirt client environment"
      (import_playbook "../service/libvirt.yml"))))
