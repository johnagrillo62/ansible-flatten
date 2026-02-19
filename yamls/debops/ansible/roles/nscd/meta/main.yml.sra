(playbook "debops/ansible/roles/nscd/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage Name Service Cache Daemon")
    (company "DebOps")
    (license "GPL-3.0")
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
        "nss"))))
