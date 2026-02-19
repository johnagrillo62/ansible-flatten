(playbook "debops/ansible/roles/tinyproxy/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Bechea Leonardo, Alin Alexandru")
    (description "Install and manage Tinyproxy service")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.2")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "tinyproxy"))))
