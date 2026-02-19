(playbook "debops/ansible/roles/slapd/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage slapd - OpenLDAP server")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.7")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "database"
        "ldap"
        "authentication"
        "olc"
        "openldap"
        "slapd"))))
