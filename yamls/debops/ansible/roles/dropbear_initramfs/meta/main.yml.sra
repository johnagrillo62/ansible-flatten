(playbook "debops/ansible/roles/dropbear_initramfs/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Robin Schneider")
    (description "Setup the dropbear ssh server in initramfs")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.1.4")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "system"
        "startup"
        "boot"
        "fde"
        "headless"
        "encryption"
        "security"
        "initramfs"
        "ssh"
        "cryptsetup"))))
