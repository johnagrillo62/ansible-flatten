(playbook "kubespray/roles/container-engine/crun/tasks/main.yml"
  (tasks
    (task "Crun | Download crun binary"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.crun) }}"))))
    (task "Copy crun binary from download dir"
      (copy 
        (src (jinja "{{ downloads.crun.dest }}"))
        (dest (jinja "{{ bin_dir }}") "/crun")
        (mode "0755")
        (remote_src "true")))))
