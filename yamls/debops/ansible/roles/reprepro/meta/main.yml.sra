(playbook "debops/ansible/roles/reprepro/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage local APT repositories with reprepro")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.9.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "development"
        "packaging"
        "apt"
        "repository"))))
