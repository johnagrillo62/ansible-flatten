(playbook "debops/ansible/roles/dhcp_probe/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Configure DHCP Probe service")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.6.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "bionic"))
        
        (name "Debian")
        (versions (list
            "stretch"
            "buster"))))
    (galaxy_tags (list
        "dhcp"
        "networking"))))
