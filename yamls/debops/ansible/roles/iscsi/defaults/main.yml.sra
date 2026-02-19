(playbook "debops/ansible/roles/iscsi/defaults/main.yml"
  (iscsi__packages (list
      "open-iscsi"
      "lvm2"))
  (iscsi__interfaces (list))
  (iscsi__portals (list))
  (iscsi__targets (list))
  (iscsi__logical_volumes (list))
  (iscsi__iqn_date (jinja "{{ ansible_date_time.year + \"-\" + ansible_date_time.month }}"))
  (iscsi__iqn_authority (jinja "{{ ansible_domain }}"))
  (iscsi__iqn (jinja "{{ (ansible_local.iscsi.iqn
                 if (ansible_local.iscsi.iqn | d())
                 else (\"iqn.\" + iscsi__iqn_date + \".\" +
                       iscsi__iqn_authority.split(\".\")[::-1] | join(\".\"))) }}"))
  (iscsi__hostname (jinja "{{ ansible_hostname }}"))
  (iscsi__initiator_name (jinja "{{ iscsi__iqn + \":\" + iscsi__hostname }}"))
  (iscsi__enabled "True")
  (iscsi__node_startup "automatic")
  (iscsi__discovery_auth "True")
  (iscsi__discovery_auth_username (jinja "{{ lookup(\"password\", secret + \"/iscsi/credentials/discovery/username\") }}"))
  (iscsi__discovery_auth_password (jinja "{{ lookup(\"password\", secret + \"/iscsi/credentials/discovery/password\") }}"))
  (iscsi__session_auth "True")
  (iscsi__session_auth_username (jinja "{{ lookup(\"password\", secret + \"/iscsi/credentials/session/username\") }}"))
  (iscsi__session_auth_password (jinja "{{ lookup(\"password\", secret + \"/iscsi/credentials/session/password\") }}"))
  (iscsi__default_options 
    (node.startup (jinja "{{ iscsi__node_startup }}"))
    (discovery.sendtargets.auth.authmethod (jinja "{{ \"CHAP\" if (iscsi__discovery_auth | d(False)) else \"None\" }}"))
    (discovery.sendtargets.auth.username (jinja "{{ iscsi__discovery_auth_username }}"))
    (discovery.sendtargets.auth.password (jinja "{{ iscsi__discovery_auth_password }}"))
    (node.session.auth.authmethod (jinja "{{ \"CHAP\" if (iscsi__session_auth | d(False)) else \"None\" }}"))
    (node.session.auth.username (jinja "{{ iscsi__session_auth_username }}"))
    (node.session.auth.password (jinja "{{ iscsi__session_auth_password }}")))
  (iscsi__default_fs_type "ext4")
  (iscsi__default_mount_options "defaults,_netdev")
  (iscsi__unattended_upgrades__dependent_blacklist (list
      "open-iscsi")))
