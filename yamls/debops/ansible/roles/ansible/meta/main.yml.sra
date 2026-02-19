(playbook "debops/ansible/roles/ansible/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install Ansible on Debian/Ubuntu host using Ansible")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.4.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "ansible"))))
