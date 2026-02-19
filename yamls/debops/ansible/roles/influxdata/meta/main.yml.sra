(playbook "debops/ansible/roles/influxdata/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Patryk Ściborek")
    (description "Configure InfluxData APT repositories")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "clustering"
        "database"
        "nosql"
        "search"
        "influxdb"
        "telegraf"
        "chronograf"
        "kapacitor"))))
