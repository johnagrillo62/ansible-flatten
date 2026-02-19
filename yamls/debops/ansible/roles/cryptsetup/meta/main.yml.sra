(playbook "debops/ansible/roles/cryptsetup/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Robin Schneider")
    (description "Setup and manage encrypted filesystems")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.2.3")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "encryption"
        "security"
        "filesystem"
        "cryptsetup"
        "dmcrypt"
        "luks"))))
