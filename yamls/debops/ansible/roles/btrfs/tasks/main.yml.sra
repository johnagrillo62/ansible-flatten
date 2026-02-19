(playbook "debops/ansible/roles/btrfs/tasks/main.yml"
  (tasks
    (task "Combine BTRFS subvolumes"
      (ansible.builtin.set_fact 
        (btrfs__subvolumes_combined (jinja "{{
                btrfs__subvolumes
      | combine(btrfs__subvolumes_host_group)
      | combine(btrfs__subvolumes_host) }}"))))
    (task "Ensure required packages are installed"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", btrfs__base_packages) }}"))
        (state "present"))
      (register "btrfs__register_packages")
      (until "btrfs__register_packages is succeeded")
      (tags (list
          "role::btrfs:pkts")))
    (task "Create BTRFS subvolumes"
      (debops.debops.btrfs_subvolume 
        (state "present")
        (path (jinja "{{ item.key }}"))
        (qgroups (jinja "{{ item.value.qgroups | d(omit) }}"))
        (commit (jinja "{{ item.value.commit | d(omit) }}"))
        (recursive (jinja "{{ item.value.recursive | d(omit) }}")))
      (when "(item.value.state | d(\"present\") == \"present\")")
      (with_dict (jinja "{{ btrfs__subvolumes_combined }}"))
      (tags (list
          "role::btrfs:subvolumes")))
    (task "Remove BTRFS subvolumes"
      (debops.debops.btrfs_subvolume 
        (state "absent")
        (path (jinja "{{ item.key }}")))
      (when "(item.value.state | d(\"present\") != \"present\")")
      (with_dict (jinja "{{ btrfs__subvolumes_combined }}"))
      (tags (list
          "role::btrfs:subvolumes")))
    (task "Set directory permissions"
      (ansible.builtin.file 
        (path (jinja "{{ item.key }}"))
        (state "directory")
        (owner (jinja "{{ item.value.dir_owner | d(omit) }}"))
        (group (jinja "{{ item.value.dir_group | d(omit) }}"))
        (mode (jinja "{{ item.value.dir_mode | d(omit) }}")))
      (when "(item.value.state | d(\"present\") == \"present\")")
      (with_dict (jinja "{{ btrfs__subvolumes_combined }}"))
      (tags (list
          "role::btrfs:subvolumes")))))
