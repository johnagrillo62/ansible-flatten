(playbook "debops/ansible/roles/x2go_server/defaults/main.yml"
  (x2go_server__base_packages (list
      (jinja "{{ [\"x2go-keyring\"] if (ansible_distribution in [\"Debian\"]) else [] }}")
      "x2goserver"
      "x2goserver-xsession"))
  (x2go_server__deploy_state "present")
  (x2go_server__apt_repo_key_fingerprint "972FD88FA0BAFB578D0476DFE1F958385BFE2B6E")
  (x2go_server__upstream_release_channel "main")
  (x2go_server__upstream_mirror_url "http://packages.x2go.org/" (jinja "{{ ansible_distribution | lower }}") "/")
  (x2go_server__upstream_repository_map 
    (Ubuntu "ppa:x2go/" (jinja "{{ x2go_server__ppa_release_channel_map[x2go_server__upstream_release_channel] }}"))
    (Linuxmint "ppa:x2go/" (jinja "{{ x2go_server__ppa_release_channel_map[x2go_server__upstream_release_channel] }}"))
    (default "deb " (jinja "{{ x2go_server__upstream_mirror_url }}") " " (jinja "{{ ansible_distribution_release }}") " " (jinja "{{ x2go_server__upstream_release_channel }}")))
  (x2go_server__ppa_release_channel_map 
    (main "stable"))
  (x2go_server__keyring__dependent_apt_keys (list
      
      (id (jinja "{{ x2go_server__apt_repo_key_fingerprint }}"))
      (repo (jinja "{{ x2go_server__upstream_repository_map[ansible_distribution]
              | d(x2go_server__upstream_repository_map[\"default\"]) }}"))
      (state (jinja "{{ \"present\" if (x2go_server__deploy_state == \"present\") else \"absent\" }}")))))
