(playbook "debops/ansible/roles/prosody/meta/main.yml"
  (collections (list
      "debops.debops"))
  (dependencies (list))
  (galaxy_info 
    (company "DebOps")
    (author "Norbert Summer")
    (description "Lightweight Jabber/XMPP server")
    (license "GPL-3.0-only")
    (min_ansible_version "2.2.0")
    (platforms (list
        
        (name "Debian")
        (versions (list
            "stretch"))
        
        (name "Ubuntu")
        (versions (list
            "xenial"
            "artful"))))
    (galaxy_tags (list
        "prosody"
        "jabber"
        "xmpp"))))
