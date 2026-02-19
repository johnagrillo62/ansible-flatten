(playbook "kubespray/roles/container-engine/gvisor/tasks/main.yml"
  (tasks
    (task "GVisor | Download runsc binary"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.gvisor_runsc) }}"))))
    (task "GVisor | Download containerd-shim-runsc-v1 binary"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.gvisor_containerd_shim) }}"))))
    (task "GVisor | Copy binaries"
      (copy 
        (src (jinja "{{ item.src }}"))
        (dest (jinja "{{ bin_dir }}") "/" (jinja "{{ item.dest }}"))
        (mode "0755")
        (remote_src "true"))
      (with_items (list
          
          (src (jinja "{{ downloads.gvisor_runsc.dest }}"))
          (dest "runsc")
          
          (src (jinja "{{ downloads.gvisor_containerd_shim.dest }}"))
          (dest "containerd-shim-runsc-v1"))))))
