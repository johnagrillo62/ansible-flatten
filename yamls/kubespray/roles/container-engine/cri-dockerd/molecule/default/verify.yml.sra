(playbook "kubespray/roles/container-engine/cri-dockerd/molecule/default/verify.yml"
  (tasks
    (task "Test cri-dockerd"
      (import_playbook "../../../molecule/test_cri.yml")
      (vars 
        (container_manager "cri-dockerd")
        (cri_socket "unix:///var/run/cri-dockerd.sock")
        (cri_name "docker")))
    (task "Test running a container with docker"
      (import_playbook "../../../molecule/test_runtime.yml")
      (vars 
        (container_runtime "docker")))))
