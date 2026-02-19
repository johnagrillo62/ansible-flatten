(playbook "kubespray/roles/kubernetes/control-plane/tasks/kubeadm-secondary.yml"
  (tasks
    (task "Set kubeadm_discovery_address"
      (set_fact 
        (kubeadm_discovery_address (jinja "{%- if \"127.0.0.1\" in kube_apiserver_endpoint or \"localhost\" in kube_apiserver_endpoint -%}") " " (jinja "{{ first_kube_control_plane_address | ansible.utils.ipwrap }}") ":" (jinja "{{ kube_apiserver_port }}") " " (jinja "{%- else -%}") " " (jinja "{{ kube_apiserver_endpoint | regex_replace('https://', '') }}") " " (jinja "{%- endif %}")))
      (tags (list
          "facts")))
    (task "Obtain kubeadm certificate key for joining control planes nodes"
      (block (list
          
          (name "Upload certificates so they are fresh and not expired")
          (command (jinja "{{ bin_dir }}") "/kubeadm init phase --config " (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml upload-certs --upload-certs")
          (register "kubeadm_upload_cert")
          (delegate_to (jinja "{{ first_kube_control_plane }}"))
          
          (name "Parse certificate key if not set")
          (set_fact 
            (kubeadm_certificate_key (jinja "{{ kubeadm_upload_cert.stdout_lines[-1] | trim }}")))))
      (when (list
          "not kube_external_ca_mode"))
      (run_once "true"))
    (task "Wait for k8s apiserver"
      (wait_for 
        (host (jinja "{{ kubeadm_discovery_address | regex_replace('\\\\]?:\\\\d+$', '') | regex_replace('^\\\\[', '') }}"))
        (port (jinja "{{ kubeadm_discovery_address.split(':')[-1] }}"))
        (timeout "180")))
    (task "Check already run"
      (debug 
        (msg (jinja "{{ kubeadm_already_run.stat.exists }}"))))
    (task "Reset cert directory"
      (shell "if [ -f /etc/kubernetes/manifests/kube-apiserver.yaml ]; then " (jinja "{{ bin_dir }}") "/kubeadm reset -f --cert-dir " (jinja "{{ kube_cert_dir }}") "; fi")
      (environment 
        (PATH (jinja "{{ bin_dir }}") ":" (jinja "{{ ansible_env.PATH }}")))
      (when (list
          "inventory_hostname != first_kube_control_plane"
          "kubeadm_already_run is not defined or not kubeadm_already_run.stat.exists"
          "not kube_external_ca_mode")))
    (task "Get kubeconfig for join discovery process"
      (command (jinja "{{ kubectl }}") " -n kube-public get cm cluster-info -o jsonpath='{.data.kubeconfig}'")
      (register "kubeconfig_file_discovery")
      (run_once "true")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (when (list
          "kubeadm_use_file_discovery"
          "kubeadm_already_run is not defined or not kubeadm_already_run.stat.exists")))
    (task "Copy discovery kubeconfig"
      (copy 
        (dest (jinja "{{ kube_config_dir }}") "/cluster-info-discovery-kubeconfig.yaml")
        (content (jinja "{{ kubeconfig_file_discovery.stdout }}"))
        (owner "root")
        (mode "0644"))
      (when (list
          "inventory_hostname != first_kube_control_plane"
          "kubeadm_use_file_discovery"
          "kubeadm_already_run is not defined or not kubeadm_already_run.stat.exists")))
    (task "Create kubeadm ControlPlane config"
      (template 
        (src "kubeadm-controlplane.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/kubeadm-controlplane.yaml")
        (mode "0640")
        (backup "true")
        (validate (jinja "{{ kubeadm_config_validate_enabled | ternary(bin_dir + '/kubeadm config validate --config %s', omit) }}")))
      (when (list
          "inventory_hostname != first_kube_control_plane"
          "not kubeadm_already_run.stat.exists")))
    (task "Joining control plane node to the cluster."
      (command (jinja "{{ bin_dir }}") "/kubeadm join --config " (jinja "{{ kube_config_dir }}") "/kubeadm-controlplane.yaml --ignore-preflight-errors=" (jinja "{{ kubeadm_ignore_preflight_errors | join(',') }}") " --skip-phases=" (jinja "{{ kubeadm_join_phases_skip | join(',') }}"))
      (throttle "1")
      (environment 
        (PATH (jinja "{{ bin_dir }}") ":" (jinja "{{ ansible_env.PATH }}")))
      (register "kubeadm_join_control_plane")
      (retries "3")
      (until "kubeadm_join_control_plane is succeeded")
      (when (list
          "inventory_hostname != first_kube_control_plane"
          "kubeadm_already_run is not defined or not kubeadm_already_run.stat.exists")))
    (task "Wait for new control plane nodes to be Ready"
      (command (jinja "{{ kubectl }}") " get nodes --selector node-role.kubernetes.io/control-plane -o jsonpath-as-json=\"{.items[*].status.conditions[?(@.type == 'Ready')]}\"
")
      (when "kubeadm_already_run.stat.exists")
      (run_once "true")
      (register "control_plane_node_ready_conditions")
      (retries (jinja "{{ control_plane_node_become_ready_tries }}"))
      (delay "5")
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (until "control_plane_node_ready_conditions.stdout | from_json | selectattr('status', '==', 'True') | length == (groups['kube_control_plane'] | length)"))))
