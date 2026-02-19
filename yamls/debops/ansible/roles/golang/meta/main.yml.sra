(playbook "debops/ansible/roles/golang/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Nick Janetakis, Maciej Delmanowski")
    (description "Install Go language support and build Go applications from sources")
    (company "DebOps")
    (license "GPLv3")
    (min_ansible_version "2.7.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "development"
        "programming"
        "golang"
        "go"))))
