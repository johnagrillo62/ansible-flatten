(playbook "debops/ansible/roles/lvm/defaults/main.yml"
  (lvm__packages (list
      "lvm2"))
  (lvm__global_use_lvmetad "True")
  (lvm__devices_filter (list
      "a|sd.*|"
      "a|vd.*|"
      "a|drbd.*|"
      "a|md.*|"
      "r|.*|"))
  (lvm__devices_global_filter (jinja "{{ lvm__devices_filter }}"))
  (lvm__config_lookup "")
  (lvm__config 
    (global 
      (use_lvmetad (jinja "{{ lvm__global_use_lvmetad }}")))
    (devices 
      (filter (jinja "{{ lvm__devices_filter }}"))
      (global_filter (jinja "{{ lvm__devices_global_filter }}"))))
  (lvm__default_fs_type "ext4")
  (lvm__default_mount_options "defaults")
  (lvm__volume_groups (list))
  (lvm__thin_pools (list))
  (lvm__logical_volumes (list)))
