(playbook "debops/ansible/roles/owncloud/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Maciej Delmanowski, Hartmut Goebel, Robin Schneider")
    (description "Install and manage ownCloud instance")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.4")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "stretch"
            "buster"))
        
        (name "Ubuntu")
        (versions (list
            "trusty"))))
    (galaxy_tags (list
        "cloud"
        "private"
        "privacy"
        "sharing"
        "files"
        "calendar"
        "contacts"
        "web"
        "owncloud"
        "nextcloud"))))
