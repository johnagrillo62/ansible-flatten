(playbook "kubespray/roles/recover_control_plane/control-plane/tasks/main.yml"
  (tasks
    (task "Wait for apiserver"
      (command (jinja "{{ kubectl }}") " get nodes")
      (environment 
        (KUBECONFIG (jinja "{{ ansible_env.HOME | default('/root') }}") "/.kube/config"))
      (register "apiserver_is_ready")
      (until "apiserver_is_ready.rc == 0")
      (retries "6")
      (delay "10")
      (changed_when "false")
      (when "groups['broken_kube_control_plane']"))
    (task "Delete broken kube_control_plane nodes from cluster"
      (command (jinja "{{ kubectl }}") " delete node " (jinja "{{ item }}"))
      (environment 
        (KUBECONFIG (jinja "{{ ansible_env.HOME | default('/root') }}") "/.kube/config"))
      (with_items (jinja "{{ groups['broken_kube_control_plane'] }}"))
      (register "delete_broken_kube_control_plane_nodes")
      (failed_when "false")
      (when "groups['broken_kube_control_plane']"))
    (task "Fail if unable to delete broken kube_control_plane nodes from cluster"
      (fail 
        (msg "Unable to delete broken kube_control_plane node: " (jinja "{{ item.item }}")))
      (loop (jinja "{{ delete_broken_kube_control_plane_nodes.results }}"))
      (changed_when "false")
      (when (list
          "groups['broken_kube_control_plane']"
          "item.rc != 0 and not 'NotFound' in item.stderr")))))
