(playbook "kubespray/roles/container-engine/nerdctl/tasks/main.yml"
  (tasks
    (task "Nerdctl | Download nerdctl"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.nerdctl) }}"))))
    (task "Nerdctl | Copy nerdctl binary from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/nerdctl")
        (dest (jinja "{{ bin_dir }}") "/nerdctl")
        (mode "0755")
        (remote_src "true")
        (owner "root")
        (group "root"))
      (become "true")
      (notify (list
          "Get nerdctl completion"
          "Install nerdctl completion")))
    (task "Nerdctl | Create configuration dir"
      (file 
        (path "/etc/nerdctl")
        (state "directory")
        (mode "0755")
        (owner "root")
        (group "root"))
      (become "true"))
    (task "Nerdctl | Install nerdctl configuration"
      (template 
        (src "nerdctl.toml.j2")
        (dest "/etc/nerdctl/nerdctl.toml")
        (mode "0644")
        (owner "root")
        (group "root"))
      (become "true"))))
