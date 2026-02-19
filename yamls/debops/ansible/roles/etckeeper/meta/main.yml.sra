(playbook "debops/ansible/roles/etckeeper/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Robin Schneider, Maciej Delmanowski")
    (description "Put /etc under version control using etckeeper")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.3")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "all"))
        
        (name "Ubuntu")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "versioning"
        "etckeeper"
        "etc"
        "system"))))
