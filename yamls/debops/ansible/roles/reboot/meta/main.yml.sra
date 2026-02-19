(playbook "debops/ansible/roles/reboot/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Julien Lecomte")
    (description "Reboot DebOps hosts")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.2.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"))))
