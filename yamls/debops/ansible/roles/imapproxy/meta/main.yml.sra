(playbook "debops/ansible/roles/imapproxy/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "David Härdeman")
    (description "Manage imapproxy, used to speed up e.g. webmail clients")
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
