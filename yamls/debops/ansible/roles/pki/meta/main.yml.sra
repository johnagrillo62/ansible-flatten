(playbook "debops/ansible/roles/pki/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (author "Maciej Delmanowski")
    (description "Bootstrap and manage internal PKI, Certificate Authorities and OpenSSL/GnuTLS certificates")
    (company "DebOps")
    (license "GPL-3.0-only")
    (min_ansible_version "2.2.0")
    (platforms (list
        
        (name "Ubuntu")
        (versions (list
            "all"))
        
        (name "Debian")
        (versions (list
            "all"))))
    (galaxy_tags (list
        "encryption"
        "hardening"
        "security"
        "pki"
        "ssl"
        "tls"
        "acme"
        "letsencrypt"))))
