(playbook "debops/ansible/roles/homeassistant/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Robin Schneider")
    (description "Setup and manage Home Assistant")
    (license "GPL-3.0-only")
    (min_ansible_version "2.2.2")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "bullseye"))))
    (galaxy_tags (list
        "automation"
        "home"
        "homeassistant"
        "iot"))))
