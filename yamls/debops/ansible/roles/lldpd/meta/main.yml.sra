(playbook "debops/ansible/roles/lldpd/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and configure LLDP service")
    (company "DebOps")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "buster"
            "bullseye"))))
    (galaxy_tags (list
        "networking"
        "lldp"
        "cdp"))))
