(playbook "kubespray/roles/remove_node/pre_remove/tasks/main.yml"
  (tasks
    (task "Remove-node | List nodes"
      (command (jinja "{{ kubectl }}") " get nodes -o go-template=" (jinja "{% raw %}") "'" (jinja "{{ range .items }}") (jinja "{{ .metadata.name }}") (jinja "{{ \"\\n\" }}") (jinja "{{ end }}") "'" (jinja "{% endraw %}"))
      (register "nodes")
      (when (list
          "groups['kube_control_plane'] | length > 0"))
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (changed_when "false")
      (run_once "true"))
    (task "Remove-node | Drain node except daemonsets resource"
      (command (jinja "{{ kubectl }}") " drain
  --force
  --ignore-daemonsets
  --grace-period " (jinja "{{ drain_grace_period }}") "
  --timeout " (jinja "{{ drain_timeout }}") "
  --delete-emptydir-data " (jinja "{{ kube_override_hostname }}"))
      (when (list
          "groups['kube_control_plane'] | length > 0"
          "kube_override_hostname in nodes.stdout_lines"))
      (register "result")
      (failed_when "result.rc != 0 and not allow_ungraceful_removal")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (until "result.rc == 0 or allow_ungraceful_removal")
      (retries (jinja "{{ drain_retries }}"))
      (delay (jinja "{{ drain_retry_delay_seconds }}")))
    (task "Remove-node | Wait until Volumes will be detached from the node"
      (command (jinja "{{ kubectl }}") " get volumeattachments -o go-template=" (jinja "{% raw %}") "'" (jinja "{{ range .items }}") (jinja "{{ .spec.nodeName }}") (jinja "{{ \"\\n\" }}") (jinja "{{ end }}") "'" (jinja "{% endraw %}"))
      (register "nodes_with_volumes")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (changed_when "false")
      (until "not (kube_override_hostname in nodes_with_volumes.stdout_lines)")
      (retries "3")
      (delay (jinja "{{ drain_grace_period }}"))
      (when (list
          "groups['kube_control_plane'] | length > 0"
          "not allow_ungraceful_removal"
          "kube_override_hostname in nodes.stdout_lines")))))
