(playbook "debops/ansible/roles/mount/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage local device and bind mounts")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.6.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"
        "filesystems"
        "mount"))))
