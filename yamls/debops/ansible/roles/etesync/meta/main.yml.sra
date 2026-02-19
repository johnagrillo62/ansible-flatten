(playbook "debops/ansible/roles/etesync/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (role_name "etcsync")
    (author "Robin Schneider")
    (description "Deploy and manage the EteSync server")
    (company "DebOps")
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
        "e2ee"
        "private"
        "privacy"
        "calendar"
        "contacts"))))
