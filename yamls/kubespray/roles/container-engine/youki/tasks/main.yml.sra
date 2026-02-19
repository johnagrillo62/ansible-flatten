(playbook "kubespray/roles/container-engine/youki/tasks/main.yml"
  (tasks
    (task "Youki | Download youki"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.youki) }}"))))
    (task "Youki | Copy youki binary from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/youki")
        (dest (jinja "{{ youki_bin_dir }}") "/youki")
        (mode "0755")
        (remote_src "true")))))
