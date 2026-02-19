(playbook "debops/ansible/roles/phpipam/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install phpIPAM, an Open Source IP Address Manager")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.4.0`")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "networking"
        "ipam"))))
