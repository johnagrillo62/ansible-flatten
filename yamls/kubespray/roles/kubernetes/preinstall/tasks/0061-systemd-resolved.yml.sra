(playbook "kubespray/roles/kubernetes/preinstall/tasks/0061-systemd-resolved.yml"
  (tasks
    (task "Create systemd-resolved drop-in directory"
      (file 
        (state "directory")
        (name "/etc/systemd/resolved.conf.d/")
        (mode "0755")))
    (task "Write Kubespray DNS settings to systemd-resolved"
      (template 
        (src "resolved.conf.j2")
        (dest "/etc/systemd/resolved.conf.d/kubespray.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify "Preinstall | Restart systemd-resolved"))))
