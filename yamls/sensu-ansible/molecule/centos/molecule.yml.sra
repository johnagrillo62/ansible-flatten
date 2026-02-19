(playbook "sensu-ansible/molecule/centos/molecule.yml"
  (scenario 
    (name "centos"))
  (platforms (list
      
      (name "centos-6")
      (image "dokken/centos-6")
      (command "/sbin/init")
      (capabilities (list
          "SYS_ADMIN"))
      (groups (list
          "sensu_checks"))
      
      (name "centos-7")
      (image "dokken/centos-7")
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
        (centos-6 
          (inspec_version "el6"))
        (centos-7 
          (inspec_version "el7"))))))
