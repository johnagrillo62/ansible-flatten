(playbook "kubespray/roles/container-engine/crictl/handlers/main.yml"
  (tasks
    (task "Get crictl completion"
      (command (jinja "{{ bin_dir }}") "/crictl completion")
      (changed_when "false")
      (register "cri_completion")
      (check_mode "false"))
    (task "Install crictl completion"
      (copy 
        (dest "/etc/bash_completion.d/crictl")
        (content (jinja "{{ cri_completion.stdout }}"))
        (mode "0644")))))
