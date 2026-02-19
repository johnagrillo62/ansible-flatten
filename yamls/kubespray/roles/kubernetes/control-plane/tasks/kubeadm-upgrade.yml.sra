(playbook "kubespray/roles/kubernetes/control-plane/tasks/kubeadm-upgrade.yml"
  (tasks
    (task "Ensure kube-apiserver is up before upgrade"
      (import_tasks "check-api.yml"))
    (task "Kubeadm | Upgrade first control plane node to " (jinja "{{ kube_version }}")
      (command "timeout -k 600s 600s " (jinja "{{ bin_dir }}") "/kubeadm upgrade apply -y v" (jinja "{{ kube_version }}") " " (jinja "{%- if kubeadm_config_api_version == 'v1beta3' %}") " --certificate-renewal=" (jinja "{{ kubeadm_upgrade_auto_cert_renewal }}") " --ignore-preflight-errors=" (jinja "{{ kubeadm_ignore_preflight_errors | join(',') }}") " --allow-experimental-upgrades --etcd-upgrade=" (jinja "{{ (etcd_deployment_type == \"kubeadm\") | lower }}") " " (jinja "{% if kubeadm_patches | length > 0 %}") "--patches=" (jinja "{{ kubeadm_patches_dir }}") (jinja "{% endif %}") " --force " (jinja "{%- else %}") " --config=" (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml " (jinja "{%- endif %}") " " (jinja "{%- if kube_version is version('1.32.0', '>=') %}") " --skip-phases=" (jinja "{{ kubeadm_init_phases_skip | join(',') }}") " " (jinja "{%- endif %}"))
      (register "kubeadm_upgrade")
      (when "inventory_hostname == first_kube_control_plane")
      (failed_when "kubeadm_upgrade.rc != 0 and \"field is immutable\" not in kubeadm_upgrade.stderr")
      (environment 
        (PATH (jinja "{{ bin_dir }}") ":" (jinja "{{ ansible_env.PATH }}"))))
    (task "Kubeadm | Upgrade other control plane nodes to " (jinja "{{ kube_version }}")
      (command (jinja "{{ bin_dir }}") "/kubeadm upgrade node " (jinja "{%- if kubeadm_config_api_version == 'v1beta3' %}") " --certificate-renewal=" (jinja "{{ kubeadm_upgrade_auto_cert_renewal }}") " --ignore-preflight-errors=" (jinja "{{ kubeadm_ignore_preflight_errors | join(',') }}") " --etcd-upgrade=" (jinja "{{ (etcd_deployment_type == \"kubeadm\") | lower }}") " " (jinja "{% if kubeadm_patches | length > 0 %}") "--patches=" (jinja "{{ kubeadm_patches_dir }}") (jinja "{% endif %}") " " (jinja "{%- else %}") " --config=" (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml " (jinja "{%- endif %}") " --skip-phases=" (jinja "{{ kubeadm_upgrade_node_phases_skip | join(',') }}"))
      (register "kubeadm_upgrade")
      (when "inventory_hostname != first_kube_control_plane")
      (failed_when "kubeadm_upgrade.rc != 0 and \"field is immutable\" not in kubeadm_upgrade.stderr")
      (environment 
        (PATH (jinja "{{ bin_dir }}") ":" (jinja "{{ ansible_env.PATH }}"))))
    (task "Update kubeadm and kubelet configmaps after upgrade"
      (command (jinja "{{ bin_dir }}") "/kubeadm init phase upload-config all --config " (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml")
      (register "kubeadm_upload_config")
      (retries "3")
      (until "kubeadm_upload_config.rc == 0")
      (when (list
          "inventory_hostname == first_kube_control_plane")))
    (task "Update kube-proxy configmap after upgrade"
      (command (jinja "{{ bin_dir }}") "/kubeadm init phase addon kube-proxy --config " (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml")
      (register "kube_proxy_upload_config")
      (retries "3")
      (until "kube_proxy_upload_config.rc == 0")
      (when (list
          "inventory_hostname == first_kube_control_plane"
          "('addon/kube-proxy' not in kubeadm_init_phases_skip)")))
    (task "Rewrite kubeadm managed etcd static pod manifests with updated configmap"
      (command (jinja "{{ bin_dir }}") "/kubeadm init phase etcd local --config " (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml")
      (when (list
          "etcd_deployment_type == \"kubeadm\""))
      (notify "Control plane | restart kubelet"))
    (task "Rewrite kubernetes control plane static pod manifests with updated configmap"
      (command (jinja "{{ bin_dir }}") "/kubeadm init phase control-plane all --config " (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml")
      (notify "Control plane | restart kubelet"))
    (task "Flush kubelet handlers"
      (meta "flush_handlers"))
    (task "Ensure kube-apiserver is up after upgrade and control plane configuration updates"
      (import_tasks "check-api.yml"))
    (task "Kubeadm | Remove binding to anonymous user"
      (command (jinja "{{ kubectl }}") " -n kube-public delete rolebinding kubeadm:bootstrap-signer-clusterinfo --ignore-not-found")
      (when "remove_anonymous_access"))
    (task "Kubeadm | clean kubectl cache to refresh api types"
      (file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (with_items (list
          "/root/.kube/cache"
          "/root/.kube/http-cache")))
    (task "Kubeadm | scale down coredns replicas to 0 if not using coredns dns_mode"
      (command (jinja "{{ kubectl }}") " -n kube-system scale deployment/coredns --replicas 0")
      (register "scale_down_coredns")
      (retries "6")
      (delay "5")
      (until "scale_down_coredns is succeeded")
      (run_once "true")
      (when (list
          "kubeadm_scale_down_coredns_enabled"
          "dns_mode not in ['coredns', 'coredns_dual']"))
      (changed_when "false"))))
