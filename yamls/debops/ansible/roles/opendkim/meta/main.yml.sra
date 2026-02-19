(playbook "debops/ansible/roles/opendkim/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and configure OpenDKIM service")
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
        "smtp"
        "milter"
        "dkim"
        "spf"
        "dmarc"
        "mail"
        "security"
        "antispam"))))
