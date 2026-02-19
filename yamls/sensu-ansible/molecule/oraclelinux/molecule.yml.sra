(playbook "sensu-ansible/molecule/oraclelinux/molecule.yml"
  (scenario 
    (name "oraclelinux"))
  (platforms (list
      
      (name "oraclelinux-7")
      (image "dokken/oraclelinux-7")
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
        (oraclelinux-7 
          (inspec_version "el7"))))))
