(playbook "debops/ansible/roles/telegraf/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Dr. Serge Victor")
    (description "Install and manage a Telegraf instance")
    (company "DebOps")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "bullseye"
            "buster"))
        
        (name "Ubuntu")
        (versions (list
            "focal"
            "bionic"))))
    (galaxy_tags (list
        "monitoring"
        "influxdb"))))
