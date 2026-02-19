(playbook "debops/ansible/roles/nslcd/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Configure LDAP support for NSS and PAM lookups")
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
        "ldap"
        "nslcd"
        "nss"
        "pam"
        "system"))))
