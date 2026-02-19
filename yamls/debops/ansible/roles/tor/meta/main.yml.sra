(playbook "debops/ansible/roles/tor/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Robin Schneider")
    (description "The Tor network aims to provide communication privacy")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.5")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "security"))))
