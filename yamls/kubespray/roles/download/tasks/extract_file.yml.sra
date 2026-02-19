(playbook "kubespray/roles/download/tasks/extract_file.yml"
  (tasks
    (task "Extract_file | Unpacking archive"
      (unarchive 
        (src (jinja "{{ download.dest }}"))
        (dest (jinja "{{ download.dest | dirname }}"))
        (owner (jinja "{{ download.owner | default(omit) }}"))
        (mode (jinja "{{ download.mode | default(omit) }}"))
        (remote_src "true")
        (extra_opts (jinja "{{ download.unarchive_extra_opts | default(omit) }}")))
      (when (list
          "download.unarchive | default(false)")))))
