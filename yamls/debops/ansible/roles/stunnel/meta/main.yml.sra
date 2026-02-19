(playbook "debops/ansible/roles/stunnel/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Create an encrypted TCP tunnel between two hosts using stunnel and SSL")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.8.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "networking"
        "tunnel"
        "ssl"))))
