(playbook "kubespray/roles/network_plugin/kube-router/tasks/main.yml"
  (tasks
    (task "Kube-router | Create annotations"
      (import_tasks "annotate.yml")
      (tags "annotate"))
    (task "Kube-router | Create config directory"
      (file 
        (path "/var/lib/kube-router")
        (state "directory")
        (owner (jinja "{{ kube_owner }}"))
        (recurse "true")
        (mode "0755")))
    (task "Kube-router | Create kubeconfig"
      (template 
        (src "kubeconfig.yml.j2")
        (dest "/var/lib/kube-router/kubeconfig")
        (mode "0644")
        (owner (jinja "{{ kube_owner }}")))
      (notify (list
          "Reset_kube_router")))
    (task "Kube-router | Slurp cni config"
      (slurp 
        (src "/etc/cni/net.d/10-kuberouter.conflist"))
      (register "cni_config_slurp")
      (ignore_errors "true"))
    (task "Kube-router | Set cni_config variable"
      (set_fact 
        (cni_config (jinja "{{ cni_config_slurp.content | b64decode | from_json }}")))
      (when (list
          "not cni_config_slurp.failed")))
    (task "Kube-router | Set host_subnet variable"
      (set_fact 
        (host_subnet (jinja "{{ cni_config | json_query('plugins[?bridge==`kube-bridge`].ipam.subnet') | first }}")))
      (when (list
          "cni_config is defined"
          "cni_config | json_query('plugins[?bridge==`kube-bridge`].ipam.subnet') | length > 0")))
    (task "Kube-router | Create cni config"
      (template 
        (src "cni-conf.json.j2")
        (dest "/etc/cni/net.d/10-kuberouter.conflist")
        (mode "0644")
        (owner (jinja "{{ kube_owner }}")))
      (notify (list
          "Reset_kube_router")))
    (task "Kube-router | Delete old configuration"
      (file 
        (path "/etc/cni/net.d/10-kuberouter.conf")
        (state "absent")))
    (task "Kube-router | Create manifest"
      (template 
        (src "kube-router.yml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/kube-router.yml")
        (mode "0644"))
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (run_once "true"))
    (task "Kube-router | Start Resources"
      (kube 
        (name "kube-router")
        (kubectl (jinja "{{ bin_dir }}") "/kubectl")
        (filename (jinja "{{ kube_config_dir }}") "/kube-router.yml")
        (resource "ds")
        (namespace "kube-system")
        (state "latest"))
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (run_once "true"))
    (task "Kube-router | Wait for kube-router pods to be ready"
      (command (jinja "{{ kubectl }}") " -n kube-system get pods -l k8s-app=kube-router -o jsonpath='{.items[?(@.status.containerStatuses[0].ready==false)].metadata.name}'")
      (register "pods_not_ready")
      (until "pods_not_ready.stdout.find(\"kube-router\")==-1")
      (retries "30")
      (delay "10")
      (ignore_errors "true")
      (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
      (run_once "true")
      (changed_when "false"))))
