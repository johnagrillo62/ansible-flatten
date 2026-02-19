(playbook "kubespray/roles/container-engine/cri-o/molecule/default/verify.yml"
  (tasks
    (task "Test CRI-O cri"
      (import_playbook "../../../molecule/test_cri.yml")
      (vars 
        (cri_socket "unix:///var/run/crio/crio.sock")
        (cri_name "cri-o")))
    (task "Test running a container with crun"
      (import_playbook "../../../molecule/test_runtime.yml")
      (vars 
        (container_runtime "crun")))))
