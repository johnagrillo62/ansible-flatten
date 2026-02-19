(playbook "debops/ansible/roles/swapfile/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Maciej Delmanowski, Robin Schneider")
    (description "Configure one or multiple swap files on a Linux system")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"))))
