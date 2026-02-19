(playbook "openshift-ansible/roles/openshift_node/tasks/gather_debug.yml"
  (tasks
    (task "Gather Debug - Get service status"
      (command "systemctl status " (jinja "{{ item }}") "
")
      (changed_when "false")
      (ignore_errors "true")
      (register "systemctl_status")
      (loop (list
          "crio"
          "kubelet")))
    (task "Gather Debug - Get complete node objects"
      (command "oc get node " (jinja "{{ ansible_nodename | lower }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=json
")
      (delegate_to "localhost")
      (changed_when "false")
      (ignore_errors "true")
      (register "oc_get"))))
