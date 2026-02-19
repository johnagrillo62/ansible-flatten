(playbook "debops/ansible/roles/dovecot/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Reto Gantenbein")
    (description "Configure Dovecot IMAP/POP3 service")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.7.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "imap"
        "pop3"
        "sieve"
        "mail"))))
