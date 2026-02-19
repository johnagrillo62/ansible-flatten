(playbook "debops/ansible/roles/apt_mirror/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage mirrors of multiple APT repositories")
    (company "DebOps")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.14.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"
        "apt"
        "mirror"
        "proxy"))))
