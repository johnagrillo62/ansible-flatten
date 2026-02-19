(playbook "sensu-ansible/molecule/ubuntu/molecule.yml"
  (scenario 
    (name "ubuntu"))
  (platforms (list
      
      (name "ubuntu-14.04")
      (image "dokken/ubuntu-14.04")
      (command "/sbin/init")
      (capabilities (list
          "SYS_ADMIN"))
      (groups (list
          "sensu_checks"))
      
      (name "ubuntu-16.04")
      (image "dokken/ubuntu-16.04")
      (command "/bin/systemd")
      (capabilities (list
          "SYS_ADMIN"))
      (groups (list
          "sensu_checks"))
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:ro"))
      
      (name "ubuntu-18.04")
      (image "dokken/ubuntu-18.04")
      (command "/bin/systemd")
      (capabilities (list
          "SYS_ADMIN"))
      (groups (list
          "sensu_checks"))
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:ro"))))
  (provisioner 
    (inventory 
      (host_vars 
        (ubuntu-14.04 
          (inspec_version "ubuntu1404"))
        (ubuntu-16.04 
          (inspec_version "ubuntu1604"))
        (ubuntu-18.04 
          (inspec_version "ubuntu1804"))))))
