(playbook "sensu-ansible/molecule/fedora/molecule.yml"
  (scenario 
    (name "fedora"))
  (platforms (list
      
      (name "fedora-30")
      (image "dokken/fedora-latest")
      (command "/usr/lib/systemd/systemd")
      (capabilities (list
          "SYS_ADMIN"))
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:ro"))
      (groups (list
          "sensu_checks"))
      
      (name "fedora-29")
      (image "dokken/fedora-29")
      (command "/usr/lib/systemd/systemd")
      (capabilities (list
          "SYS_ADMIN"))
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:ro"))
      (groups (list
          "sensu_checks"))
      
      (name "fedora-28")
      (image "dokken/fedora-28")
      (command "/usr/lib/systemd/systemd")
      (capabilities (list
          "SYS_ADMIN"))
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:ro"))
      (groups (list
          "sensu_checks"))))
  (provisioner 
    (inventory 
      (host_vars 
        (fedora-30 
          (inspec_version "el7"))
        (fedora-29 
          (inspec_version "el7"))
        (fedora-28 
          (inspec_version "el7"))))))
