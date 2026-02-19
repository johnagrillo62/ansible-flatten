(playbook "kubespray/roles/container-engine/runc/tasks/main.yml"
  (tasks
    (task "Runc | check if fedora coreos"
      (stat 
        (path "/run/ostree-booted")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "ostree"))
    (task "Runc | set is_ostree"
      (set_fact 
        (is_ostree (jinja "{{ ostree.stat.exists }}"))))
    (task "Runc | Uninstall runc package managed by package manager"
      (block (list
          
          (name "Runc | Remove package")
          (package 
            (name (jinja "{{ runc_package_name }}"))
            (state "absent"))
          
          (name "Runc | Remove orphaned binary")
          (file 
            (path "/usr/bin/runc")
            (state "absent"))
          (when "runc_bin_dir != \"/usr/bin\"")))
      (when (list
          "not is_ostree"
          "ansible_distribution != \"Flatcar Container Linux by Kinvolk\""
          "ansible_distribution != \"Flatcar\"")))
    (task "Runc | Download runc binary"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.runc) }}"))))
    (task "Copy runc binary from download dir"
      (copy 
        (src (jinja "{{ downloads.runc.dest }}"))
        (dest (jinja "{{ runc_bin_dir }}") "/runc")
        (mode "0755")
        (remote_src "true")))))
