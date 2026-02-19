(playbook "kubespray/roles/kubernetes/preinstall/handlers/main.yml"
  (tasks
    (task "Preinstall | apply resolvconf cloud-init"
      (command "/usr/bin/coreos-cloudinit --from-file " (jinja "{{ resolveconf_cloud_init_conf }}"))
      (listen "Preinstall | update resolvconf for Flatcar Container Linux by Kinvolk")
      (when "ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))
    (task "Preinstall | reload NetworkManager"
      (service 
        (name "NetworkManager.service")
        (state "restarted"))
      (listen "Preinstall | update resolvconf for networkmanager"))
    (task "Preinstall | reload kubelet"
      (service 
        (name "kubelet")
        (state "restarted"))
      (listen (list
          "Preinstall | propagate resolvconf to k8s components"
          "Preinstall | update resolvconf for Flatcar Container Linux by Kinvolk"
          "Preinstall | update resolvconf for networkmanager"))
      (notify (list
          "Preinstall | kube-controller configured"
          "Preinstall | kube-apiserver configured"
          "Preinstall | restart kube-controller-manager docker"
          "Preinstall | restart kube-controller-manager crio/containerd"
          "Preinstall | restart kube-apiserver docker"
          "Preinstall | restart kube-apiserver crio/containerd"))
      (when "not dns_early | bool"))
    (task "Preinstall | kube-apiserver configured"
      (stat 
        (path (jinja "{{ kube_manifest_dir }}") "/kube-apiserver.yaml")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (listen "Preinstall | propagate resolvconf to k8s components")
      (register "kube_apiserver_set")
      (when "('kube_control_plane' in group_names) and dns_mode != 'none' and resolvconf_mode == 'host_resolvconf'"))
    (task "Preinstall | kube-controller configured"
      (stat 
        (path (jinja "{{ kube_manifest_dir }}") "/kube-controller-manager.yaml")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (listen "Preinstall | propagate resolvconf to k8s components")
      (register "kube_controller_set")
      (when "('kube_control_plane' in group_names) and dns_mode != 'none' and resolvconf_mode == 'host_resolvconf'"))
    (task "Preinstall | restart kube-controller-manager docker"
      (shell "set -o pipefail && " (jinja "{{ docker_bin_dir }}") "/docker ps -f name=k8s_POD_kube-controller-manager* -q | xargs --no-run-if-empty " (jinja "{{ docker_bin_dir }}") "/docker rm -f")
      (listen "Preinstall | propagate resolvconf to k8s components")
      (args 
        (executable "/bin/bash"))
      (when (list
          "container_manager == \"docker\""
          "('kube_control_plane' in group_names)"
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "kube_controller_set.stat.exists")))
    (task "Preinstall | restart kube-controller-manager crio/containerd"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl pods --name kube-controller-manager* -q | xargs -I% --no-run-if-empty bash -c '" (jinja "{{ bin_dir }}") "/crictl stopp % && " (jinja "{{ bin_dir }}") "/crictl rmp %'")
      (listen "Preinstall | propagate resolvconf to k8s components")
      (args 
        (executable "/bin/bash"))
      (register "preinstall_restart_controller_manager")
      (retries "10")
      (delay "1")
      (until "preinstall_restart_controller_manager.rc == 0")
      (when (list
          "container_manager in ['crio', 'containerd']"
          "('kube_control_plane' in group_names)"
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "kube_controller_set.stat.exists")))
    (task "Preinstall | restart kube-apiserver docker"
      (shell "set -o pipefail && " (jinja "{{ docker_bin_dir }}") "/docker ps -f name=k8s_POD_kube-apiserver* -q | xargs --no-run-if-empty " (jinja "{{ docker_bin_dir }}") "/docker rm -f")
      (listen "Preinstall | propagate resolvconf to k8s components")
      (args 
        (executable "/bin/bash"))
      (when (list
          "container_manager == \"docker\""
          "('kube_control_plane' in group_names)"
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "kube_apiserver_set.stat.exists")))
    (task "Preinstall | restart kube-apiserver crio/containerd"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl pods --name kube-apiserver* -q | xargs -I% --no-run-if-empty bash -c '" (jinja "{{ bin_dir }}") "/crictl stopp % && " (jinja "{{ bin_dir }}") "/crictl rmp %'")
      (listen "Preinstall | propagate resolvconf to k8s components")
      (args 
        (executable "/bin/bash"))
      (register "preinstall_restart_apiserver")
      (retries "10")
      (until "preinstall_restart_apiserver.rc == 0")
      (delay "1")
      (when (list
          "container_manager in ['crio', 'containerd']"
          "('kube_control_plane' in group_names)"
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "kube_apiserver_set.stat.exists")))
    (task "Preinstall | wait for the apiserver to be running"
      (uri 
        (url (jinja "{{ kube_apiserver_endpoint }}") "/healthz")
        (validate_certs "false"))
      (listen "Preinstall | propagate resolvconf to k8s components")
      (register "result")
      (until "result.status == 200")
      (retries "60")
      (delay "1")
      (when (list
          "dns_late"
          "('kube_control_plane' in group_names)"
          "dns_mode != 'none'"
          "resolvconf_mode == 'host_resolvconf'"
          "not ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"] and not is_fedora_coreos")))
    (task "Preinstall | Restart systemd-resolved"
      (service 
        (name "systemd-resolved")
        (state "restarted")))
    (task "Preinstall | restart ntp"
      (service 
        (name (jinja "{{ ntp_service_name }}"))
        (state "restarted"))
      (when "ntp_enabled"))))
