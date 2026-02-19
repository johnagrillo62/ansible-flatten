(playbook "debops/ansible/roles/redis_sentinel/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Configure Redis Sentinel instances")
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
        "redis"))))
