(playbook "debops/ansible/roles/libvirtd_qemu/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Manage libvirtd QEMU configuration")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.2.3")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "virtualization"
        "kvm"
        "qemu"))))
