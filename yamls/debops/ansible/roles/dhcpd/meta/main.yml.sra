(playbook "debops/ansible/roles/dhcpd/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and configure ISC DHCP Server")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "buster"))))
    (galaxy_tags (list
        "networking"
        "dhcp"
        "pxe"
        "bootp"))))
