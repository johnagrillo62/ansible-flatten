(playbook "kubespray/roles/container-engine/cri-dockerd/tasks/main.yml"
  (tasks
    (task "Runc | Download cri-dockerd binary"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.cri_dockerd) }}"))))
    (task "Copy cri-dockerd binary from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/cri-dockerd")
        (dest (jinja "{{ bin_dir }}") "/cri-dockerd")
        (mode "0755")
        (remote_src "true"))
      (notify (list
          "Restart and enable cri-dockerd")))
    (task "Generate cri-dockerd systemd unit files"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/etc/systemd/system/" (jinja "{{ item }}"))
        (mode "0644")
        (validate "sh -c '[ -f /usr/bin/systemd/system/factory-reset.target ] || exit 0 && systemd-analyze verify %s:" (jinja "{{ item }}") "'"))
      (with_items (list
          "cri-dockerd.service"
          "cri-dockerd.socket"))
      (notify (list
          "Restart and enable cri-dockerd")))
    (task "Flush handlers"
      (meta "flush_handlers"))))
