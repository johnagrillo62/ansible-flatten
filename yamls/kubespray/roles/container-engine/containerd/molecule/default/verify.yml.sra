(playbook "kubespray/roles/container-engine/containerd/molecule/default/verify.yml"
  (tasks
    (task "Test containerd CRI"
      (import_playbook "../../../molecule/test_cri.yml")
      (vars 
        (container_manager "containerd")
        (cri_socket "unix:///var/run/containerd/containerd.sock")
        (cri_name "containerd")))
    (task "Test nerdctl"
      (hosts "all")
      (gather_facts "false")
      (tasks (list
          
          (name "Get kubespray defaults")
          (import_role 
            (name "../../../../../kubespray_defaults"))
          
          (name "Test nerdctl commands")
          (command (jinja "{{ bin_dir }}") "/nerdctl " (jinja "{{ item | join(' ') }}"))
          (vars 
            (image "quay.io/kubespray/hello-world:latest"))
          (loop (list
              (list
                "pull"
                (jinja "{{ image }}"))
              (list
                "save"
                "-o"
                "/tmp/hello-world.tar"
                (jinja "{{ image }}"))
              (list
                "load"
                "-i"
                "/tmp/hello-world.tar")
              (list
                "-n"
                "k8s.io"
                "run"
                (jinja "{{ image }}"))))
          (register "nerdctl")
          
          (name "Check log from running a container")
          (assert 
            (that (list
                "('Hello from Docker' in nerdctl.results[3].stdout)")))))
      (become "true"))))
