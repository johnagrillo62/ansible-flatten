(playbook "debops/ansible/roles/apt_cacher_ng/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Robin Schneider")
    (description "Install and manage the caching HTTP proxy Apt-Cacher NG")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.0.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"
        "proxy"
        "caching"
        "packages"
        "apt"))))
