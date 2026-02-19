(playbook "debops/ansible/roles/bind/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "David Härdeman")
    (description "Configure the BIND DNS server")
    (license "GPL-3.0-only")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "bind"
        "bind9"
        "named"
        "dns"))))
