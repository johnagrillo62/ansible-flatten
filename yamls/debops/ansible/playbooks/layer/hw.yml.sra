(playbook "debops/ansible/playbooks/layer/hw.yml"
  (tasks
    (task "Configure Hardware RAID monitoring"
      (import_playbook "../service/hwraid.yml"))
    (task "Configure GRUB bootloader"
      (import_playbook "../service/grub.yml"))))
