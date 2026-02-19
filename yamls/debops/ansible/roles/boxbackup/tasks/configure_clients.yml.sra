(playbook "debops/ansible/roles/boxbackup/tasks/configure_clients.yml"
  (tasks
    (task "Install Box Backup client package"
      (ansible.builtin.package 
        (name "boxbackup-client")
        (state "present"))
      (register "boxbackup__register_client_packages")
      (until "boxbackup__register_client_packages is succeeded"))
    (task "Set backup softlimit size for client hosts"
      (ansible.builtin.set_fact 
        (boxbackup_softlimit (jinja "{{ (ansible_mounts | sum(attribute=\"size_total\") / 1024 / 1024
                              + boxbackup_softlimit_padding) | int }}")))
      (when "(boxbackup_softlimit is undefined or not boxbackup_softlimit)"))
    (task "Set backup hardlimit size for client hosts"
      (ansible.builtin.set_fact 
        (boxbackup_hardlimit (jinja "{{ (boxbackup_softlimit | float * boxbackup_hardlimit_multiplier | float) | int }}")))
      (when "(boxbackup_hardlimit is undefined or not boxbackup_hardlimit)"))
    (task "Create accounts for client hosts"
      (ansible.builtin.command "bbstoreaccounts create " (jinja "{{ boxbackup_account }}") " " (jinja "{{ boxbackup_discnum }}") " " (jinja "{{ boxbackup_softlimit }}") "M " (jinja "{{ boxbackup_hardlimit }}") "M")
      (args 
        (creates (jinja "{{ boxbackup_storage }}") "/backup/" (jinja "{{ boxbackup_account }}") "/info.rfw"))
      (delegate_to (jinja "{{ boxbackup_server }}")))
    (task "Make sure that boxbackup client directories exists"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0700"))
      (with_items (list
          "/etc/boxbackup"
          "/etc/boxbackup/bbackupd"
          "/etc/boxbackup/servers/" (jinja "{{ boxbackup_server }}"))))
    (task "Check if encryption key exists on Ansible Controller"
      (ansible.builtin.stat 
        (path (jinja "{{ secret + \"/storage/boxbackup/clients/\" + ansible_fqdn + \"/\" + boxbackup_account + \"-FileEncKeys.raw\" }}")))
      (register "boxbackup_register_enckeys")
      (delegate_to "localhost")
      (become "False"))
    (task "Download BoxBackup encryption key from archive"
      (ansible.builtin.copy 
        (src (jinja "{{ secret + \"/storage/boxbackup/clients/\" + ansible_fqdn + \"/\" + boxbackup_account + \"-FileEncKeys.raw\" }}"))
        (dest "/etc/boxbackup/bbackupd/" (jinja "{{ boxbackup_account }}") "-FileEncKeys.raw")
        (owner "root")
        (group "root")
        (mode "0600"))
      (when "boxbackup_register_enckeys.stat.exists")
      (notify (list
          "Restart boxbackup-client")))
    (task "Create encryption key on client hosts"
      (ansible.builtin.command "openssl rand -out /etc/boxbackup/bbackupd/" (jinja "{{ boxbackup_account }}") "-FileEncKeys.raw " (jinja "{{ boxbackup_encrypt_bits }}"))
      (args 
        (creates "/etc/boxbackup/bbackupd/" (jinja "{{ boxbackup_account }}") "-FileEncKeys.raw"))
      (notify (list
          "Restart boxbackup-client")))
    (task "Archive client encryption key"
      (ansible.builtin.fetch 
        (src "/etc/boxbackup/bbackupd/" (jinja "{{ boxbackup_account }}") "-FileEncKeys.raw")
        (dest (jinja "{{ secret }}") "/storage/boxbackup/clients/" (jinja "{{ ansible_fqdn }}") "/" (jinja "{{ boxbackup_account }}") "-FileEncKeys.raw")
        (flat "yes")))
    (task "Install notification script on client hosts"
      (ansible.builtin.template 
        (src "etc/boxbackup/bbackupd/NotifySysadmin.sh.j2")
        (dest "/etc/boxbackup/bbackupd/NotifySysadmin.sh")
        (owner "root")
        (group "root")
        (mode "0700")))
    (task "Configure client hosts"
      (ansible.builtin.template 
        (src "etc/boxbackup/bbackupd.conf.j2")
        (dest "/etc/boxbackup/bbackupd.conf")
        (owner "root")
        (group "root")
        (mode "0600"))
      (notify (list
          "Restart boxbackup-client")))))
