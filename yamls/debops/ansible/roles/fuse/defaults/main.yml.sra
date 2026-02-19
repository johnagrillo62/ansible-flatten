(playbook "debops/ansible/roles/fuse/defaults/main.yml"
  (fuse_base_packages (list
      "fuse"))
  (fuse_mount_max "default")
  (fuse_user_allow_other "False")
  (fuse_restrict_access "False")
  (fuse_group "fuse")
  (fuse_permissions "0660")
  (fuse_users (list))
  (fuse_users_host_group (list))
  (fuse_users_host (list)))
