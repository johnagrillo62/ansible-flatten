(playbook "debops/ansible/roles/nfs/defaults/main.yml"
  (nfs__base_packages (list
      "nfs-common"))
  (nfs__packages (list))
  (nfs__kerberos "False")
  (nfs__default_mount_type "nfs4")
  (nfs__base_mount_options (list
      "proto=tcp"
      "port=2049"
      "_netdev"))
  (nfs__security_mount_options (jinja "{{ [\"sec=krb5p\"] if nfs__kerberos | bool else [\"sec=sys\"] }}"))
  (nfs__default_mount_options (list
      "noatime"
      "nosuid"
      "nodev"
      "hard"
      "intr"))
  (nfs__shares (list))
  (nfs__group_shares (list))
  (nfs__host_shares (list)))
