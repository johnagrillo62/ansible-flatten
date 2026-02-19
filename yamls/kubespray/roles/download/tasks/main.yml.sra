(playbook "kubespray/roles/download/tasks/main.yml"
  (tasks
    (task "Download | Prepare working directories and variables"
      (import_tasks "prep_download.yml")
      (when (list
          "not skip_downloads | default(false)"))
      (tags (list
          "download"
          "upload")))
    (task "Download | Get kubeadm binary and list of required images"
      (include_tasks "prep_kubeadm_images.yml")
      (when (list
          "not skip_downloads | default(false)"
          "('kube_control_plane' in group_names)"))
      (tags (list
          "download"
          "upload")))
    (task "Download | Download files / images"
      (include_tasks (jinja "{{ include_file }}"))
      (loop (jinja "{{ downloads | combine(kubeadm_images) | dict2items }}"))
      (vars 
        (download (jinja "{{ download_defaults | combine(item.value) }}"))
        (include_file "download_" (jinja "{% if download.container %}") "container" (jinja "{% else %}") "file" (jinja "{% endif %}") ".yml"))
      (when (list
          "not skip_downloads | default(false)"
          "download.enabled"
          "item.value.enabled"
          "(not (item.value.container | default(false))) or (item.value.container and download_container)"
          "(download_run_once and inventory_hostname == download_delegate) or (group_names | intersect(download.groups) | length)")))))
