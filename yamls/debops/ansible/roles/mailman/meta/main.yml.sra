(playbook "debops/ansible/roles/mailman/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and manage Mailman, Mailing List Manager")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.0.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "bionic"
            "focal"))
        
        (name "Debian")
        (versions (list
            "buster"
            "bullseye"))))
    (galaxy_tags (list
        "mailman"
        "mail"
        "mailinglist"
        "postfix"))))
