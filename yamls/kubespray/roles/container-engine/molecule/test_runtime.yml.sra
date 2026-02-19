(playbook "kubespray/roles/container-engine/molecule/test_runtime.yml"
    (play
    (name "Test container runtime")
    (hosts "all")
    (gather_facts "false")
    (become "true")
    (roles
      
        (role "../../kubespray_defaults"))
    (tasks
      (task "Copy test container files"
        (template 
          (src (jinja "{{ item }}") ".j2")
          (dest "/tmp/" (jinja "{{ item }}"))
          (owner "root")
          (mode "0644"))
        (loop (list
            "container.json"
            "sandbox.json")))
      (task "Check running a container with runtime " (jinja "{{ container_runtime }}")
        (block (list
            
            (name "Run container")
            (command 
              (argv (list
                  (jinja "{{ bin_dir }}") "/crictl"
                  "run"
                  "--with-pull"
                  "--runtime"
                  (jinja "{{ container_runtime }}")
                  "/tmp/container.json"
                  "/tmp/sandbox.json")))
            
            (name "Check log file")
            (slurp 
              (src "/tmp/" (jinja "{{ container_runtime }}") "1.0.log"))
            (register "log_file")
            (failed_when "log_file is failed or 'Hello from Docker' not in (log_file.content | b64decode)
")))
        (rescue (list
            
            (name "Display container manager config on error")
            (command (jinja "{{ bin_dir }}") "/crictl info")
            
            (name "Check container manager logs")
            (command "journalctl -u " (jinja "{{ container_manager }}"))
            (failed_when "true")))))))
