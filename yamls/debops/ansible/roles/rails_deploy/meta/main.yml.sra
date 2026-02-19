(playbook "debops/ansible/roles/rails_deploy/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Nick Janetakis")
    (description "Deploy and monitor rails applications")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "1.7.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "development"
        "ruby"
        "rails"))))
