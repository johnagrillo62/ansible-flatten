(playbook "debops/ansible/roles/elasticsearch/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Nick Janetakis, Maciej Delmanowski")
    (description "Install and manage Elasticsearch database clusters")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.3.0")
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
        "elasticsearch"))))
