(playbook "debops/ansible/roles/zabbix_agent/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Julien Lecomte")
    (description "Configure Zabbix agent")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.4.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "buster"
            "bullseye"))))
    (galaxy_tags (list
        "zabbix"))))
