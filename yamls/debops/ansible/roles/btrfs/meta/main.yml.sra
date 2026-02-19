(playbook "debops/ansible/roles/btrfs/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Robin Schneider")
    (description "Manage Btrfs")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.3")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"
        "securystem"
        "btrfs"))))
