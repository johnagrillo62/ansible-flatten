(playbook "debops/ansible/roles/elastic_co/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Configure Elastic APT repositories")
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
        "clustering"
        "database"
        "nosql"
        "search"
        "elasticsearch"
        "kibana"
        "logstash"
        "filebeat"
        "metricbeat"
        "packetbeat"
        "heartbeat"))))
