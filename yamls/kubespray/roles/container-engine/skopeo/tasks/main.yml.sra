(playbook "kubespray/roles/container-engine/skopeo/tasks/main.yml"
  (tasks
    (task "Skopeo | check if fedora coreos"
      (stat 
        (path "/run/ostree-booted")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "ostree"))
    (task "Skopeo | set is_ostree"
      (set_fact 
        (is_ostree (jinja "{{ ostree.stat.exists }}"))))
    (task "Skopeo | Uninstall skopeo package managed by package manager"
      (package 
        (name "skopeo")
        (state "absent"))
      (when (list
          "not (is_ostree or (ansible_distribution == \"Flatcar Container Linux by Kinvolk\") or (ansible_distribution == \"Flatcar\"))"))
      (ignore_errors "true"))
    (task "Skopeo | Download skopeo binary"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.skopeo) }}"))))
    (task "Copy skopeo binary from download dir"
      (copy 
        (src (jinja "{{ downloads.skopeo.dest }}"))
        (dest (jinja "{{ bin_dir }}") "/skopeo")
        (mode "0755")
        (remote_src "true")))))
