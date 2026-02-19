(playbook "debops/ansible/roles/icinga_web/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage Icinga 2 Web installation")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.4.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "xenial"
            "bionic"))
        
        (name "Debian")
        (versions (list
            "stretch"
            "buster"))))
    (galaxy_tags (list
        "monitoring"
        "icinga"
        "nagios"))))
