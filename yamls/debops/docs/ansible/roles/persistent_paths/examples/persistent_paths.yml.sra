(playbook "debops/docs/ansible/roles/persistent_paths/examples/persistent_paths.yml"
  (persistent_paths__dependent_paths 
    (50_debops_cryptsetup 
      (by_role "debops.cryptsetup")
      (paths (list
          "/etc/fstab"
          "/etc/crypttab"
          "/var/local/keyfiles"
          "/var/backups/luks_header_backup"
          "/media"))))
  (persistent_paths__group_paths 
    (70_local_mlocate 
      (paths (list
          "/var/lib/mlocate")))))
