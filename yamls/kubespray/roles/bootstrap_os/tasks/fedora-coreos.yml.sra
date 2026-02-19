(playbook "kubespray/roles/bootstrap_os/tasks/fedora-coreos.yml"
  (tasks
    (task "Check if bootstrap is needed"
      (raw "which python")
      (register "need_bootstrap")
      (failed_when "false")
      (changed_when "false")
      (tags (list
          "facts")))
    (task "Remove podman network cni"
      (raw "podman network rm podman")
      (become "true")
      (ignore_errors "true")
      (when "need_bootstrap.rc != 0"))
    (task "Clean up possible pending packages on fedora coreos"
      (raw "export http_proxy=" (jinja "{{ http_proxy | default('') }}") ";rpm-ostree cleanup -p }}")
      (become "true")
      (when "need_bootstrap.rc != 0"))
    (task "Install required packages on fedora coreos"
      (raw "export http_proxy=" (jinja "{{ http_proxy | default('') }}") ";rpm-ostree install --allow-inactive " (jinja "{{ fedora_coreos_packages | join(' ') }}"))
      (become "true")
      (when "need_bootstrap.rc != 0"))
    (task "Reboot immediately for updated ostree"
      (raw "nohup bash -c 'sleep 5s && shutdown -r now'")
      (ignore_unreachable "true")
      (become "true")
      (ignore_errors "true")
      (when "need_bootstrap.rc != 0"))
    (task "Wait for the reboot to complete"
      (wait_for_connection 
        (timeout "240")
        (connect_timeout "20")
        (delay "5")
        (sleep "5"))
      (when "need_bootstrap.rc != 0"))))
