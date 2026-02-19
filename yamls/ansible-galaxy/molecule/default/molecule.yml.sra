(playbook "ansible-galaxy/molecule/default/molecule.yml"
  (dependency 
    (name "galaxy")
    (options 
      (force "false")
      (role-file "molecule/_common/requirements.yml")
      (requirements-file "molecule/_common/requirements.yml")))
  (driver 
    (name "docker"))
  (platforms (list
      
      (name "galaxy-scenario-default")
      (image "${FROM_IMAGE:-centos:7}")
      (command "")
      (volumes (list
          "/sys/fs/cgroup:/sys/fs/cgroup:rw"))
      (privileged "true")
      (dockerfile "../_common/Dockerfile.j2")
      (pre_build_image "false")))
  (provisioner 
    (name "ansible")
    (env 
      (GALAXY_VERSION "${GALAXY_VERSION:-dev}")))
  (verifier 
    (name "ansible")))
