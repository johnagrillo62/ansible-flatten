(playbook "debops/ansible/roles/docker_gen/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install and manage docker-gen, file generator which uses Docker metadata")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.8.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "cloud"
        "docker"
        "templates"))))
