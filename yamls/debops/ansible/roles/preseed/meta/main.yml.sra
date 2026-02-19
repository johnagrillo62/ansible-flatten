(playbook "debops/ansible/roles/preseed/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Maciej Delmanowski, Robin Schneider")
    (description "Provide Debian Preseed configuration files over HTTP")
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
        "bootstrap"
        "bootstrapping"
        "installation"
        "deployment"))))
