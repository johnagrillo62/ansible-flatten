(playbook "debops/ansible/playbooks/layer/sys.yml"
  (tasks
    (task "Configure mount points"
      (import_playbook "../service/mount.yml"))
    (task "Configure network information database"
      (import_playbook "../service/netbase.yml"))
    (task "Configure sysnews service"
      (import_playbook "../service/sysnews.yml"))
    (task "Configure kernel modules"
      (import_playbook "../service/kmod.yml"))
    (task "Configure sysfs attributes"
      (import_playbook "../service/sysfs.yml"))
    (task "Configure swap files"
      (import_playbook "../service/swapfile.yml"))
    (task "Configure LVM subsystem"
      (import_playbook "../service/lvm.yml"))
    (task "Configure NFS server service"
      (import_playbook "../service/nfs_server.yml"))
    (task "Configure NFS client service"
      (import_playbook "../service/nfs.yml"))
    (task "Configure gitusers environment"
      (import_playbook "../service/gitusers.yml"))
    (task "Configure OpenLDAP service"
      (import_playbook "../service/slapd.yml"))
    (task "Configure nslcd service"
      (import_playbook "../service/nslcd.yml"))
    (task "Configure nscd service"
      (import_playbook "../service/nscd.yml"))
    (task "Configure sssd service"
      (import_playbook "../service/sssd.yml"))
    (task "Configure iSCSI devices"
      (import_playbook "../service/iscsi.yml"))
    (task "Configure cryptsetup subsystem"
      (import_playbook "../service/cryptsetup.yml"))
    (task "Configure QubesOS persistent paths"
      (import_playbook "../service/persistent_paths.yml"))
    (task "Configure external APT repositories"
      (import_playbook "../service/extrepo.yml"))
    (task "Configure NeuroDebian APT repository"
      (import_playbook "../service/neurodebian.yml"))
    (task "Configure dropbear SSH server in initramfs"
      (import_playbook "../service/dropbear_initramfs.yml"))))
