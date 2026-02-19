(playbook "debops/ansible/roles/rspamd/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "David Härdeman")
    (description "Install and manage Rspamd service")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.3.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "mail"
        "spam"
        "smtp"
        "antispam"))))
