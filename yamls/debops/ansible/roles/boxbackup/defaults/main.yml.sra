(playbook "debops/ansible/roles/boxbackup/defaults/main.yml"
  (boxbackup_server (jinja "{{ hostvars[groups.debops_boxbackup[0]][\"ansible_fqdn\"] }}"))
  (boxbackup_allow (list))
  (boxbackup_storage "/var/local/boxbackup")
  (boxbackup_listenaddresses "0.0.0.0")
  (boxbackup_verbose "no")
  (boxbackup_account (jinja "{{ (ansible_fqdn | sha1)[:8] }}"))
  (boxbackup_softlimit null)
  (boxbackup_hardlimit null)
  (boxbackup_softlimit_padding "1024")
  (boxbackup_hardlimit_multiplier "1.5")
  (boxbackup_email "backup")
  (boxbackup_locations 
    (/etc "ExcludeFile = /etc/boxbackup/bbackupd/" (jinja "{{ boxbackup_account }}") "-FileEncKeys.raw
")
    (/home null)
    (/opt null)
    (/root null)
    (/srv null)
    (/usr/local null)
    (/var "ExcludeDir = /var/spool/postfix/dev
"))
  (boxbackup_locations_custom null))
