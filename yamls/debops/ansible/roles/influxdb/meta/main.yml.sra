(playbook "debops/ansible/roles/influxdb/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Pedro Luis López, Bechea Leonardo, Alin Alexandru")
    (description "Install and manage InfluxDB server")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "stretch"
            "buster"))))
    (galaxy_tags (list
        "clustering"
        "database"
        "nosql"
        "search"
        "monitoring"
        "influxdb"))))
