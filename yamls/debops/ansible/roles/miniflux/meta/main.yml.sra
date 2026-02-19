(playbook "debops/ansible/roles/miniflux/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Berkhan Berkdemir")
    (description "Install and manage a Miniflux instance")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.8.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "cloud"
        "private"
        "privacy"))))
