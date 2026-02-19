(playbook "debops/ansible/roles/mosquitto/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage a Mosquitto MQTT broker")
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
        "mqtt"
        "queue"
        "broker"
        "iot"))))
