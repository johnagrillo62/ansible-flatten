(playbook "debops/ansible/roles/python/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage Python environment")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.4.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "development"
        "pip"
        "python"
        "python2"
        "python3"
        "programming"
        "virtualenv"))))
