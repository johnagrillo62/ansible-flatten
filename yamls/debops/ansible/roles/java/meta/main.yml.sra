(playbook "debops/ansible/roles/java/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Nick Janetakis")
    (description "Manage Java OpenJRE/OpenJDK environment")
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
        "java"
        "development"
        "jre"
        "jdk"
        "openjdk"
        "openjre"))))
