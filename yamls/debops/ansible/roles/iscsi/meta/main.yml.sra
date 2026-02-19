(playbook "debops/ansible/roles/iscsi/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage iSCSI Initiator configuration")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.8.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "iscsi"
        "storage"
        "networking"))))
