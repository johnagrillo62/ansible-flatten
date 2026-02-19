(playbook "debops/ansible/roles/libuser/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Bechea Leonardo, Alin Alexandru")
    (description "Install and manage Libuser service")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.8")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "libuser"))))
