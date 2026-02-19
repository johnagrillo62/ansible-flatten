(playbook "debops/ansible/roles/controller/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Prepare host to be used as Ansible Controller")
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
        "ansible"
        "debops"))))
