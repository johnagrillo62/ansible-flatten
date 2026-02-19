(playbook "debops/ansible/roles/iscsi/tasks/manage_lvm.yml"
  (tasks
    (task "Unmount filesystems if requested"
      (ansible.posix.mount 
        (name (jinja "{{ item.mount }}"))
        (src (jinja "{{ \"/dev/mapper/\" + item.vg + \"-\" + item.lv }}"))
        (fstype (jinja "{{ item.fs_type | d(iscsi__default_fs_type) }}"))
        (state "absent"))
      (with_items (jinja "{{ iscsi__logical_volumes }}"))
      (when "iscsi__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and item.mount | d(False) and (item.state is defined and item.state == 'absent')"))
    (task "Remove Logical Volumes if requested"
      (community.general.lvol 
        (vg (jinja "{{ item.vg }}"))
        (lv (jinja "{{ item.lv }}"))
        (size (jinja "{{ item.size }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (state "absent"))
      (with_items (jinja "{{ iscsi__logical_volumes }}"))
      (when "iscsi__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and item.state | d() and item.state == 'absent'"))
    (task "Manage LVM Volume Groups"
      (community.general.lvg 
        (vg (jinja "{{ item.item.lvm_vg }}"))
        (pvs (jinja "{{ item.devicenodes | join(\",\") }}"))
        (state (jinja "{{ item.item.lvm_state | d(\"present\") }}"))
        (pesize (jinja "{{ item.item.lvm_pesize | d(omit) }}"))
        (force (jinja "{{ item.item.lvm_force | d(omit) }}"))
        (vg_options (jinja "{{ item.item.lvm_options | d(omit) }}")))
      (with_items (jinja "{{ iscsi__register_targets.results }}"))
      (when "iscsi__register_targets | d(False) and iscsi__register_targets.results | d() and item.devicenodes | d() and item.item.lvm_vg | d()"))
    (task "Manage LVM Logical Volumes"
      (community.general.lvol 
        (vg (jinja "{{ item.vg }}"))
        (lv (jinja "{{ item.lv }}"))
        (size (jinja "{{ item.size }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (state "present"))
      (with_items (jinja "{{ iscsi__logical_volumes }}"))
      (when "iscsi__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and (item.state is undefined or item.state != 'absent')"))
    (task "Manage filesystems"
      (community.general.filesystem 
        (dev (jinja "{{ \"/dev/mapper/\" + item.vg + \"-\" + item.lv }}"))
        (fstype (jinja "{{ item.fs_type | d(iscsi__default_fs_type) }}"))
        (force (jinja "{{ item.fs_force | d(omit) }}"))
        (opts (jinja "{{ item.fs_opts | d(omit) }}")))
      (with_items (jinja "{{ iscsi__logical_volumes }}"))
      (when "iscsi__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and (item.state is undefined or item.state != 'absent') and ((item.mount | d() and (item.fs is undefined or item.fs | d()) or item.fs | d()))"))
    (task "Manage mount points"
      (ansible.posix.mount 
        (name (jinja "{{ item.mount }}"))
        (src (jinja "{{ \"/dev/mapper/\" + item.vg + \"-\" + item.lv }}"))
        (fstype (jinja "{{ item.fs_type | d(iscsi__default_fs_type) }}"))
        (opts (jinja "{{ item.mount_opts | d(iscsi__default_mount_options) }}"))
        (state (jinja "{{ item.mount_state | d(\"mounted\") }}"))
        (dump (jinja "{{ item.mount_dump | d(omit) }}"))
        (passno (jinja "{{ item.mount_passno | d(omit) }}"))
        (fstab (jinja "{{ item.mount_fstab | d(omit) }}")))
      (with_items (jinja "{{ iscsi__logical_volumes }}"))
      (when "iscsi__logical_volumes | d(False) and item.vg | d() and item.lv | d() and item.size | d() and item.mount | d(False) and (item.state is undefined or item.state != 'absent')"))))
