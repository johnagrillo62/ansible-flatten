(playbook "debops/ansible/roles/postfix/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and manage Postfix SMTP service")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.8.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "smtp"
        "mail"
        "lmtp"
        "submission"))))
