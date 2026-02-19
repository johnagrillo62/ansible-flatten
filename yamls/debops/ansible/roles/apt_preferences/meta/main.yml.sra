(playbook "debops/ansible/roles/apt_preferences/meta/main.yml"
  (allow_duplicates "True")
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski, Robin Schneider")
    (description "Manage APT pins in /etc/apt/preferences.d/")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.7.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"
        "apt"))))
