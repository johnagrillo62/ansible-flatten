(playbook "debops/ansible/roles/roundcube/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Reto Gantenbein")
    (description "Manage Roundcube, a browser-based IMAP client written in PHP")
    (company "DebOps")
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
        "debops"
        "email"
        "mail"
        "imap"
        "web"))))
