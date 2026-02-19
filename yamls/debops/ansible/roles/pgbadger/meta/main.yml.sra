(playbook "debops/ansible/roles/pgbadger/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage pgBadger, PostgreSQL log analyzer")
    (company "DebOps")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.3.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "database"
        "postgresql"
        "logging"
        "metrics"
        "analytics"))))
