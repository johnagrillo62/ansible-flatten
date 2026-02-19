(playbook "debops/ansible/roles/mariadb_server/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and manage a MariaDB / MySQL server")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.2.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "mariadb"
        "mysql"
        "percona"
        "sql"
        "database"))))
