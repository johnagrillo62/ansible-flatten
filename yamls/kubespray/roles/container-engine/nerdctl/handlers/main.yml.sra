(playbook "kubespray/roles/container-engine/nerdctl/handlers/main.yml"
  (tasks
    (task "Get nerdctl completion"
      (command (jinja "{{ bin_dir }}") "/nerdctl completion bash")
      (changed_when "false")
      (register "nerdctl_completion")
      (check_mode "false"))
    (task "Install nerdctl completion"
      (copy 
        (dest "/etc/bash_completion.d/nerdctl")
        (content (jinja "{{ nerdctl_completion.stdout }}"))
        (mode "0644")))))
