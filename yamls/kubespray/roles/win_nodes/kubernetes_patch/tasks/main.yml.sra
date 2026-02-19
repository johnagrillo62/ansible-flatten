(playbook "kubespray/roles/win_nodes/kubernetes_patch/tasks/main.yml"
  (tasks
    (task "Ensure that user manifests directory exists"
      (file 
        (path (jinja "{{ kubernetes_user_manifests_path }}") "/kubernetes")
        (state "directory")
        (recurse "true"))
      (tags (list
          "init"
          "cni")))
    (task "Apply kube-proxy nodeselector"
      (block (list
          
          (name "Check current nodeselector for kube-proxy daemonset")
          (command (jinja "{{ kubectl }}") " get ds kube-proxy --namespace=kube-system -o jsonpath={.spec.template.spec.nodeSelector." (jinja "{{ kube_proxy_nodeselector | regex_replace('\\.', '\\\\.') }}") "}")
          (register "current_kube_proxy_state")
          (retries "60")
          (delay "5")
          (until "current_kube_proxy_state is succeeded")
          (changed_when "false")
          
          (name "Apply nodeselector patch for kube-proxy daemonset")
          (command (jinja "{{ kubectl }}") " patch ds kube-proxy --namespace=kube-system --type=strategic -p '{\"spec\":{\"template\":{\"spec\":{\"nodeSelector\":{\"" (jinja "{{ kube_proxy_nodeselector }}") "\":\"linux\"} }}}}'
")
          (register "patch_kube_proxy_state")
          (when "current_kube_proxy_state.stdout | trim | lower != \"linux\"")
          
          (debug 
            (msg (jinja "{{ patch_kube_proxy_state.stdout_lines }}")))
          (when "patch_kube_proxy_state is not skipped")
          
          (debug 
            (msg (jinja "{{ patch_kube_proxy_state.stderr_lines }}")))
          (when "patch_kube_proxy_state is not skipped")))
      (tags "init")
      (when (list
          "kube_proxy_deployed")))))
