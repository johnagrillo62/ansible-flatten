(playbook "openshift-ansible/roles/openshift_node/tasks/apply_machine_config.yml"
  (tasks
    (task "Create temp directory"
      (tempfile 
        (state "directory"))
      (register "temp_dir"))
    (task "Get worker machine current config name"
      (command "oc get node " (jinja "{{ ansible_nodename | lower }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.metadata.annotations.machineconfiguration\\.openshift\\.io/desiredConfig}'
")
      (delegate_to "localhost")
      (register "oc_get")
      (until (list
          "oc_get.stdout != ''"))
      (retries "36")
      (delay "5"))
    (task "Set l_worker_machine_config_name"
      (set_fact 
        (l_worker_machine_config_name (jinja "{{ oc_get.stdout }}"))))
    (task "Get worker ignition config"
      (command "oc get machineconfig " (jinja "{{ l_worker_machine_config_name }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=json
")
      (delegate_to "localhost")
      (register "oc_get")
      (until (list
          "oc_get.stdout != ''"))
      (retries "36")
      (delay "5"))
    (task "Write worker ignition config to file"
      (copy 
        (content (jinja "{{ (oc_get.stdout | from_json).spec.config }}"))
        (dest (jinja "{{ temp_dir.path }}") "/worker_ignition_config.json")))
    (task "Get machine-config-operator image"
      (command "oc get daemonset machine-config-daemon --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --namespace=openshift-machine-config-operator --output=jsonpath='{.spec.template.spec.containers[?(@.name==\"machine-config-daemon\")].image}'
")
      (delegate_to "localhost")
      (register "oc_get")
      (until (list
          "oc_get.stdout != ''"))
      (retries "36")
      (delay "5"))
    (task "Set l_mcd_image fact"
      (set_fact 
        (l_mcd_image (jinja "{{ oc_get.stdout }}"))))
    (task
      (import_tasks "proxy.yml"))
    (task
      (block (list
          
          (name "Pull MCD image")
          (command "podman pull --tls-verify=" (jinja "{{ openshift_node_tls_verify }}") " --authfile /var/lib/kubelet/config.json " (jinja "{{ l_mcd_image }}"))
          (register "podman_pull")
          (until "podman_pull.stdout != ''")
          (retries "12")
          (delay "10")
          
          (name "Apply machine config")
          (command "podman run " (jinja "{{ podman_mounts }}") " " (jinja "{{ podman_flags }}") " " (jinja "{{ mcd_command }}"))
          (vars 
            (podman_flags "--pid=host --privileged --rm --entrypoint=/usr/bin/machine-config-daemon -ti " (jinja "{{ l_mcd_image }}"))
            (podman_mounts "-v /:/rootfs")
            (mcd_command "start --node-name " (jinja "{{ ansible_nodename | lower }}") " --once-from " (jinja "{{ temp_dir.path }}") "/worker_ignition_config.json --skip-reboot"))))
      (environment 
        (http_proxy (jinja "{{ http_proxy | default('')}}"))
        (https_proxy (jinja "{{https_proxy | default('')}}"))
        (no_proxy (jinja "{{ no_proxy | default('')}}"))))
    (task "Remove temp directory"
      (file 
        (path (jinja "{{ temp_dir.path }}"))
        (state "absent")))
    (task "Reboot the host and wait for it to come back"
      (reboot null))
    (task
      (block (list
          
          (name "Wait for node to report ready")
          (command "oc get node " (jinja "{{ ansible_nodename | lower }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --output=jsonpath='{.status.conditions[?(@.type==\"Ready\")].status}'
")
          (delegate_to "localhost")
          (register "oc_get")
          (until (list
              "oc_get.stdout == \"True\""))
          (retries "30")
          (delay "20")
          (changed_when "false")))
      (rescue (list
          
          (import_tasks "gather_debug.yml")
          
          (name "DEBUG - Node failed to report ready")
          (fail 
            (msg "Node failed to report ready")))))))
