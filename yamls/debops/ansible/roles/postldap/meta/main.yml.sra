(playbook "debops/ansible/roles/postldap/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Rainer 'rei' Schuth")
    (description "Configure Postfix to use Virtual Mail users")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.7.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "mail"
        "postfix"
        "ldap"))))
