(playbook "yaml/roles/xmpp/tasks/prosody.yml"
  (tasks
    (task "Ensure repository key for Prosody is in place"
      (apt_key "url=https://prosody.im/files/prosody-debian-packages.key state=present")
      (tags (list
          "dependencies")))
    (task "Add Prosody repository"
      (apt_repository "repo=\"deb http://packages.prosody.im/debian " (jinja "{{ ansible_distribution_release }}") " main\"")
      (tags (list
          "dependencies")))
    (task "Install Prosody and dependencies from official repository"
      (apt "pkg=" (jinja "{{ item }}") " update_cache=yes")
      (with_items (list
          "prosody"
          "lua-sec"))
      (tags (list
          "dependencies")))
    (task "Add prosody user to ssl-cert group"
      (user "name=prosody group=ssl-cert"))
    (task "Add cert postrenew task"
      (copy "src=etc_letsencrypt_postrenew_prosody.sh dest=/etc/letsencrypt/postrenew/prosody.sh mode=0755"))
    (task "Create Prosody data directory"
      (file "state=directory path=/decrypted/prosody owner=prosody group=prosody"))
    (task "Configure Prosody"
      (template "src=prosody.cfg.lua.j2 dest=/etc/prosody/prosody.cfg.lua group=prosody owner=root mode=0644")
      (notify "restart prosody"))
    (task "Create Prosody accounts"
      (command "prosodyctl register " (jinja "{{ item.name }}") " " (jinja "{{ prosody_virtual_domain }}") " \"" (jinja "{{ item.password }}") "\"")
      (with_items (jinja "{{ prosody_accounts }}"))
      (tags (list
          "skip_ansible_lint")))
    (task "Set firewall rules for Prosody"
      (ufw "rule=allow port=" (jinja "{{ item }}") " proto=tcp")
      (with_items (list
          "5222"
          "5269"))
      (tags "ufw"))))
