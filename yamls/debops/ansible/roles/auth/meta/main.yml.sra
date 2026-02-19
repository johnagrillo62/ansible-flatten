(playbook "debops/ansible/roles/auth/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Set up basic user authentication and authorization")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.6")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"))))
