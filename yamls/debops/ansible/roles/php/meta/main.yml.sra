(playbook "debops/ansible/roles/php/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Mariano Barcia, Maciej Delmanowski")
    (description "Install and manage PHP environment")
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
        "development"
        "web"
        "php"
        "php5"
        "php7"))))
