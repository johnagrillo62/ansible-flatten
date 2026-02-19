(playbook "debops/ansible/roles/persistent_paths/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Robin Schneider")
    (description "Ensure paths are stored on persistent storage")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.4")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "persistent"
        "persistence"
        "qubesos"
        "templatebasedvm"
        "appvm"))))
