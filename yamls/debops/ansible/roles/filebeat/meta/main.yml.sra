(playbook "debops/ansible/roles/filebeat/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage Filebeat, a log shipper for Elasticsearch")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "xenial"
            "bionic"
            "focal"))
        
        (name "Debian")
        (versions (list
            "stretch"
            "buster"
            "bullseye"))))
    (galaxy_tags (list
        "elasticsearch"
        "logs"
        "logging"
        "syslog"))))
