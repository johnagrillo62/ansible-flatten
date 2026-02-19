(playbook "debops/ansible/roles/dhcrelay/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Imre Jonk")
    (description "Install and configure ISC DHCP Relay Agent")
    (company "DebOps")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "buster"))))
    (galaxy_tags (list
        "networking"
        "dhcp"))))
