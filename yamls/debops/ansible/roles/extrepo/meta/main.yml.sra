(playbook "debops/ansible/roles/extrepo/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage external APT sources using extrepo")
    (company "DebOps")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.9.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"
        "packages"
        "apt"))))
