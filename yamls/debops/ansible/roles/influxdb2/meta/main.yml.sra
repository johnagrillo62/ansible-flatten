(playbook "debops/ansible/roles/influxdb2/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and manage InfluxDBv2 server")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "clustering"
        "database"
        "nosql"
        "search"
        "monitoring"
        "influxdb"))))
