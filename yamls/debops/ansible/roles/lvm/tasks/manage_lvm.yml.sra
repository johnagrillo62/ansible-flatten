(playbook "debops/ansible/roles/lvm/tasks/manage_lvm.yml"
  (tasks
    (task "Rescan LVM Volume Groups"
      (ansible.builtin.command "vgscan")
      (register "lvm__register_vgscan")
      (changed_when "lvm__register_vgscan.changed | bool")
      (when "((lvm__register_devices_filter | d() and lvm__register_devices_filter is changed) or (lvm__register_devices_global_filter | d() and lvm__register_devices_global_filter is changed))"))
    (task "Unmount filesystems if requested"
      (ansible.posix.mount 
        (name (jinja "{{ item.mount }}"))
        (src (jinja "{{ \"/dev/mapper/\" + item.vg | regex_replace(\"-\", \"--\") + \"-\" + item.lv | regex_replace(\"-\", \"--\") }}"))
        (fstype (jinja "{{ item.fs_type | d(lvm__default_fs_type) }}"))
        (state "absent"))
      (with_items (jinja "{{ lvm__logical_volumes }}"))
      (when "lvm__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and item.mount | d(False) and item.state | d('present') == 'absent'"))
    (task "Remove Logical Volumes if requested"
      (community.general.lvol 
        (vg (jinja "{{ item.vg }}"))
        (lv (jinja "{{ item.lv }}"))
        (size (jinja "{{ item.size }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (state "absent"))
      (with_items (jinja "{{ lvm__logical_volumes }}"))
      (when "lvm__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and item.state | d('present') == 'absent'"))
    (task "Manage LVM Volume Groups"
      (community.general.lvg 
        (vg (jinja "{{ item.vg }}"))
        (pvs (jinja "{{ item.pvs if item.pvs is string else (item.pvs | join(\",\")) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (pesize (jinja "{{ item.pesize | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (vg_options (jinja "{{ item.options | d(omit) }}")))
      (with_items (jinja "{{ lvm__volume_groups }}"))
      (when "item.vg | d(False) and item.pvs | d(False)"))
    (task "Manage LVM Thin Pools"
      (community.general.lvol 
        (vg (jinja "{{ item.vg }}"))
        (thinpool (jinja "{{ item.thinpool }}"))
        (size (jinja "{{ item.size }}"))
        (opts (jinja "{{ item.opts | d(omit) }}")))
      (with_items (jinja "{{ lvm__thin_pools }}"))
      (when "lvm__thin_pools | d(False) and item.vg | d() and item.thinpool | d() and item.size | d() and item.state | d('present') != 'absent'"))
    (task "Manage LVM Logical Volumes"
      (community.general.lvol 
        (lv (jinja "{{ item.lv }}"))
        (vg (jinja "{{ item.vg }}"))
        (size (jinja "{{ item.size }}"))
        (opts (jinja "{{ item.opts | d(omit) }}"))
        (thinpool (jinja "{{ item.thinpool | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (shrink (jinja "{{ item.force | d(False) }}"))
        (state "present"))
      (with_items (jinja "{{ lvm__logical_volumes }}"))
      (when "lvm__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and item.state | d('present') != 'absent'")
      (register "lvm__register_logical_volumes"))
    (task "Manage filesystems"
      (community.general.filesystem 
        (dev (jinja "{{ \"/dev/mapper/\" + item.vg | regex_replace(\"-\", \"--\") + \"-\" + item.lv | regex_replace(\"-\", \"--\") }}"))
        (fstype (jinja "{{ item.fs_type | d(lvm__default_fs_type) }}"))
        (force (jinja "{{ item.fs_force | d(omit) }}"))
        (opts (jinja "{{ item.fs_opts | d(omit) }}"))
        (resizefs (jinja "{{ item.fs_resizefs | d(omit) }}")))
      (with_items (jinja "{{ lvm__logical_volumes }}"))
      (when "lvm__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and item.state | d('present') != 'absent' and ((item.mount | d() and item.fs | d(True)) or item.fs | d()) and (not ansible_check_mode or (ansible_check_mode and lvm__register_logical_volumes is not changed))"))
    (task "Manage mount points"
      (ansible.posix.mount 
        (name (jinja "{{ item.mount }}"))
        (src (jinja "{{ \"/dev/mapper/\" + item.vg | regex_replace(\"-\", \"--\") + \"-\" + item.lv | regex_replace(\"-\", \"--\") }}"))
        (fstype (jinja "{{ item.fs_type | d(lvm__default_fs_type) }}"))
        (opts (jinja "{{ item.mount_opts | d(lvm__default_mount_options) }}"))
        (state (jinja "{{ item.mount_state | d(\"mounted\") }}"))
        (dump (jinja "{{ item.mount_dump | d(omit) }}"))
        (passno (jinja "{{ item.mount_passno | d(omit) }}"))
        (fstab (jinja "{{ item.mount_fstab | d(omit) }}")))
      (with_items (jinja "{{ lvm__logical_volumes }}"))
      (when "lvm__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and item.fs | d(True) and item.mount | d() and item.state | d('present') != 'absent'"))))
