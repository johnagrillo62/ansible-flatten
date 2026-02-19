(playbook "kubespray/roles/container-engine/crictl/tasks/main.yml"
  (tasks
    (task "Crictl | Download crictl"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.crictl) }}"))))
    (task "Install crictl config"
      (template 
        (src "crictl.yaml.j2")
        (dest "/etc/crictl.yaml")
        (owner "root")
        (mode "0644")))
    (task "Copy crictl binary from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/crictl")
        (dest (jinja "{{ bin_dir }}") "/crictl")
        (mode "0755")
        (remote_src "true"))
      (notify (list
          "Get crictl completion"
          "Install crictl completion")))))
