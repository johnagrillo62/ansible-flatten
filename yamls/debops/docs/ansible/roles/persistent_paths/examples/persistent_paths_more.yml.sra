(playbook "debops/docs/ansible/roles/persistent_paths/examples/persistent_paths_more.yml"
  (persistent_paths__paths 
    (50_debops_persistent_paths_present 
      (by_role "debops.persistent_paths")
      (paths (list
          "/var/lib/man-db"
          "/usr/local"
          "/usr/local/bin")))
    (50_debops_persistent_paths_absent 
      (by_role "debops.persistent_paths")
      (state "absent")
      (paths (list
          "/tmp/absent")))))
