(playbook "debops/ansible/roles/lxd/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Configure and manage LXD service")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.8.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "bionic"))
        
        (name "Debian")
        (versions (list
            "buster"
            "bullseye"))))
    (galaxy_tags (list
        "container"
        "lxc"
        "lxd"
        "virtualization"))))
