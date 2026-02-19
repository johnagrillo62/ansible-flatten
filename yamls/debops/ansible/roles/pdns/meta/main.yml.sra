(playbook "debops/ansible/roles/pdns/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Imre Jonk, CipherMail B.V.")
    (description "Manage PowerDNS Authoritative Server")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.10.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "buster"
            "bullseye"))))
    (galaxy_tags (list
        "powerdns"
        "pdns"
        "authoritative"
        "dns"))))
