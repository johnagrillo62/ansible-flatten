(playbook "debops/ansible/roles/snapshot_snapper/defaults/main.yml"
  (snapshot_snapper__base_packages (list
      "snapper"))
  (snapshot_snapper__packages (list
      "mlocate"))
  (snapshot_snapper__templates )
  (snapshot_snapper__host_group_templates )
  (snapshot_snapper__host_templates )
  (snapshot_snapper__volumes (list))
  (snapshot_snapper__host_group_volumes (list))
  (snapshot_snapper__host_volumes (list))
  (snapshot_snapper__auto_reinit "True")
  (snapshot_snapper__directory ".snapshots")
  (snapshot_snapper__divert_files (list
      "/etc/updatedb.conf"
      "/etc/snapper/config-templates/default")))
