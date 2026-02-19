(playbook "debops/ansible/roles/global_handlers/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Maciej Delmanowski")
    (description "Provide handlers to other Ansible roles")
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
        "handlers"
        "ansible"
        "systemd"
        "sysvinit"
        "services"))))
