(playbook "kubespray/roles/kubernetes-apps/cluster_roles/tasks/main.yml"
  (tasks
    (task "Kubernetes Apps | Wait for kube-apiserver"
      (uri 
        (url (jinja "{{ kube_apiserver_endpoint }}") "/healthz")
        (validate_certs "false")
        (client_cert (jinja "{{ kube_apiserver_client_cert }}"))
        (client_key (jinja "{{ kube_apiserver_client_key }}")))
      (register "result")
      (until "result.status == 200")
      (retries "10")
      (delay "6")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Kubernetes Apps | Add ClusterRoleBinding to admit nodes"
      (template 
        (src "node-crb.yml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/node-crb.yml")
        (mode "0640"))
      (register "node_crb_manifest")
      (when (list
          "rbac_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Apply workaround to allow all nodes with cert O=system:nodes to register"
      (kube 
        (name "kubespray:system:node")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "clusterrolebinding")
        (filename (jinja "{{ kube_config_dir }}") "/node-crb.yml")
        (state "latest"))
      (register "result")
      (until "result is succeeded")
      (retries "10")
      (delay "6")
      (when (list
          "rbac_enabled"
          "node_crb_manifest.changed"
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Kubernetes Apps | Remove old webhook ClusterRole"
      (kube 
        (name "system:node-webhook")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "clusterrole")
        (state "absent"))
      (when (list
          "rbac_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags "node-webhook"))
    (task "Kubernetes Apps | Remove old webhook ClusterRoleBinding"
      (kube 
        (name "system:node-webhook")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "clusterrolebinding")
        (state "absent"))
      (when (list
          "rbac_enabled"
          "inventory_hostname == groups['kube_control_plane'][0]"))
      (tags "node-webhook"))
    (task "PriorityClass | Copy k8s-cluster-critical-pc.yml file"
      (copy 
        (src "k8s-cluster-critical-pc.yml")
        (dest (jinja "{{ kube_config_dir }}") "/k8s-cluster-critical-pc.yml")
        (mode "0640"))
      (when "inventory_hostname == groups['kube_control_plane'] | last"))
    (task "PriorityClass | Create k8s-cluster-critical"
      (kube 
        (name "k8s-cluster-critical")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (resource "PriorityClass")
        (filename (jinja "{{ kube_config_dir }}") "/k8s-cluster-critical-pc.yml")
        (state "latest"))
      (register "result")
      (until "result is succeeded")
      (retries "10")
      (delay "6")
      (when "inventory_hostname == groups['kube_control_plane'] | last"))))
