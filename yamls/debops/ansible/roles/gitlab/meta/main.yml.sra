(playbook "debops/ansible/roles/gitlab/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install, upgrade and manage GitLab Omnibus instance")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "gitlab"
        "gitlabci"
        "git"
        "webapp"
        "rails"
        "development"
        "programming"
        "ci"))))
