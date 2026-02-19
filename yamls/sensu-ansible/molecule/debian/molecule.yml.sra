(playbook "sensu-ansible/molecule/debian/molecule.yml"
  (scenario 
    (name "debian"))
  (platforms (list
      
      (name "debian-8")
      (image "dokken/debian-8")
      (command "/lib/systemd/systemd")
      (privileged "yes")
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:ro"))
      (groups (list
          "sensu_checks"))
      
      (name "debian-9")
      (image "dokken/debian-9")
      (command "/lib/systemd/systemd")
      (capabilities (list
          "SYS_ADMIN"))
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:ro"))
      (groups (list
          "sensu_checks"))))
  (provisioner 
    (inventory 
      (host_vars 
        (debian-8 
          (inspec_version "ubuntu1604"))
        (debian-9 
          (inspec_version "ubuntu1604"))))))
