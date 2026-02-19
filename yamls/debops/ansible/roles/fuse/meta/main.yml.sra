(playbook "debops/ansible/roles/fuse/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Robin Schneider")
    (description "Install and configure Filesystem in Userspace (FUSE)")
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
        "fuse"
        "hardening"))))
