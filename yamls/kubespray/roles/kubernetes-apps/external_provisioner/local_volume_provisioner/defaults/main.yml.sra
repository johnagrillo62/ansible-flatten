(playbook "kubespray/roles/kubernetes-apps/external_provisioner/local_volume_provisioner/defaults/main.yml"
  (local_volume_provisioner_namespace "kube-system")
  (local_volume_provisioner_nodelabels (list))
  (local_volume_provisioner_tolerations (list))
  (local_volume_provisioner_use_node_name_only "false")
  (local_volume_provisioner_storage_classes "{
  \"" (jinja "{{ local_volume_provisioner_storage_class | default('local-storage') }}") "\": {
    \"host_dir\": \"" (jinja "{{ local_volume_provisioner_base_dir | default('/mnt/disks') }}") "\",
    \"mount_dir\": \"" (jinja "{{ local_volume_provisioner_mount_dir | default('/mnt/disks') }}") "\",
    \"volume_mode\": \"Filesystem\",
    \"fs_type\": \"ext4\"
  }
}
")
  (local_volume_provisioner_log_level "2"))
