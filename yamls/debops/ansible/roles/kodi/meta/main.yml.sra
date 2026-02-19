(playbook "debops/ansible/roles/kodi/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Robin Schneider")
    (description "Setup and manage Kodi")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.5")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "buster"))))
    (galaxy_tags (list
        "kodi"
        "home"
        "htpc"
        "mediacenter"
        "media"
        "player"))))
