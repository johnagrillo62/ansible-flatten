(playbook "debops/ansible/roles/unattended_upgrades/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski, Robin Schneider")
    (description "Configure unattended upgrades on Debian-based hosts")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.0.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "apt"
        "system"
        "security"))))
