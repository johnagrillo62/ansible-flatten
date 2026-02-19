(playbook "debops/ansible/roles/dnsmasq/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski, Robin Schneider")
    (description "Install and configure dnsmasq")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.6.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "dhcp"
        "dns"
        "pxe"
        "tftp"))))
