(playbook "debops/ansible/roles/fhs/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Create base directory hierarchy used by DebOps roles")
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
        "system"))))
