(playbook "debops/ansible/roles/rstudio_server/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Configure RStudio Server, an Integrated Development Environment for R")
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
        "rlang"
        "rstudio"
        "ide"
        "web"
        "programming"
        "development"
        "statistics"))))
