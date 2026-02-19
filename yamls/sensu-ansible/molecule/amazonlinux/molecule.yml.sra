(playbook "sensu-ansible/molecule/amazonlinux/molecule.yml"
  (scenario 
    (name "amazonlinux"))
  (platforms (list
      
      (name "amazonlinux-1")
      (image "dokken/amazonlinux")
      (command "/sbin/init")
      (capabilities (list
          "SYS_ADMIN"))
      (groups (list
          "sensu_checks"))
      
      (name "amazonlinux-2")
      (image "dokken/amazonlinux-2")
      (command "/usr/lib/systemd/systemd")
      (capabilities (list
          "SYS_ADMIN"))
      (groups (list
          "sensu_checks"))
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:ro"))))
  (provisioner 
    (inventory 
      (host_vars 
        (amazonlinux-1 
          (inspec_version "el6"))
        (amazonlinux-2 
          (inspec_version "el7"))))))
