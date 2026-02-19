(playbook "debops/ansible/roles/neurodebian/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Robin Schneider")
    (description "Install packages from the NeuroDebian repository")
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
        "science"
        "neuroscience"
        "education"
        "research"
        "apt"))))
