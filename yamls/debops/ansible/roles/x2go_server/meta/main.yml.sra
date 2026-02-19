(playbook "debops/ansible/roles/x2go_server/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Robin Schneider")
    (description "Setup and manage the server-side of X2Go")
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
        "desktop"
        "remote"
        "x11"
        "ssh"))))
