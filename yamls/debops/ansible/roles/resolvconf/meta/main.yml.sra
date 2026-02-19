(playbook "debops/ansible/roles/resolvconf/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Configure system-wide DNS resolver")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.7.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "xenial"
            "bionic"))
        
        (name "Debian")
        (versions (list
            "stretch"
            "buster"))))
    (galaxy_tags (list
        "dns"
        "resolvconf"
        "tinc"
        "dnsmasq"
        "unbound"
        "bind"
        "networking"
        "nameservers"))))
