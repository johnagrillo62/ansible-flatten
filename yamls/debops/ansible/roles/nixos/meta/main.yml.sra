(playbook "debops/ansible/roles/nixos/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage NixOS system configuration using Ansible")
    (company "DebOps")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.0.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "GenericLinux")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "nixos"
        "system"
        "configuration"))))
