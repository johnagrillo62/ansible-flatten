(playbook "debops/ansible/roles/opensearch/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Imre Jonk, CipherMail B.V.")
    (description "Install and manage OpenSearch")
    (license "GPL-3.0-or-later")
    (min_ansible_version "2.10.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "bullseye"))))
    (galaxy_tags (list
        "database"
        "nosql"
        "opensearch"))))
