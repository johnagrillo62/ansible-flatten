(playbook "debops/ansible/roles/mcli/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Install MinIO Client (mc) binary on Debian/Ubuntu host")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.7.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "xenial"
            "bionic"))
        
        (name "Debian")
        (versions (list
            "stretch"
            "buster"
            "bullseye"))))
    (galaxy_tags (list
        "s3"
        "storage"
        "minio"))))
