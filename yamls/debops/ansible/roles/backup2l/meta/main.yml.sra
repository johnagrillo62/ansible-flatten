(playbook "debops/ansible/roles/backup2l/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage backup2l service")
    (company "DebOps")
    (license "GPL-3.0")
    (min_ansible_version "2.4.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "archive"
        "backup"))))
