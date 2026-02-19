(playbook "debops/ansible/roles/btrfs/defaults/main.yml"
  (btrfs__base_packages (list
      "btrfs-progs"))
  (btrfs__subvolumes )
  (btrfs__subvolumes_host_group )
  (btrfs__subvolumes_host ))
