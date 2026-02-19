(playbook "ansible-galaxy/meta/main.yml"
  (galaxy_info 
    (namespace "galaxyproject")
    (role_name "galaxy")
    (author "The Galaxy Project")
    (description "Install and manage a Galaxy (http://galaxyproject.org/) server.")
    (company "The Galaxy Project")
    (license "AFL v3.0")
    (min_ansible_version "2.10")
    (github_branch "main")
    (platforms (list
        
        (name "EL")
        (versions (list
            "all"))
        
        (name "GenericUNIX")
        (versions (list
            "all"
            "any"))
        
        (name "Fedora")
        (versions (list
            "all"))
        
        (name "Amazon")
        (versions (list
            "all"))
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "GenericLinux")
        (versions (list
            "all"
            "any"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"
        "web")))
  (dependencies (list))
  (allow_duplicates "yes"))
