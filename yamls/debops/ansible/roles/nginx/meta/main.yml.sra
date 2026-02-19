(playbook "debops/ansible/roles/nginx/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski, Robin Schneider")
    (description "Install and manage nginx webserver")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.5")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "nginx"
        "web"
        "webserver"))))
