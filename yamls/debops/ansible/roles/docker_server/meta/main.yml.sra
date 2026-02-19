(playbook "debops/ansible/roles/docker_server/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and configure Docker Engine")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.9.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "virtualization"
        "cloud"
        "docker"
        "containers"))))
