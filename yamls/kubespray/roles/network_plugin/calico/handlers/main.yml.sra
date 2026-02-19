(playbook "kubespray/roles/network_plugin/calico/handlers/main.yml"
  (tasks
    (task "Delete 10-calico.conflist"
      (file 
        (path "/etc/cni/net.d/10-calico.conflist")
        (state "absent"))
      (listen "Reset_calico_cni")
      (when "calico_cni_config is defined"))
    (task "Calico | delete calico-node docker containers"
      (shell "set -o pipefail && " (jinja "{{ docker_bin_dir }}") "/docker ps -af name=k8s_POD_calico-node* -q | xargs --no-run-if-empty " (jinja "{{ docker_bin_dir }}") "/docker rm -f")
      (listen "Reset_calico_cni")
      (args 
        (executable "/bin/bash"))
      (register "docker_calico_node_remove")
      (until "docker_calico_node_remove is succeeded")
      (retries "5")
      (when (list
          "container_manager in [\"docker\"]"
          "calico_cni_config is defined")))
    (task "Calico | delete calico-node crio/containerd containers"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl pods --name calico-node-* -q | xargs -I% --no-run-if-empty bash -c \"" (jinja "{{ bin_dir }}") "/crictl stopp % && " (jinja "{{ bin_dir }}") "/crictl rmp %\"")
      (listen "Reset_calico_cni")
      (args 
        (executable "/bin/bash"))
      (register "crictl_calico_node_remove")
      (until "crictl_calico_node_remove is succeeded")
      (retries "5")
      (when (list
          "container_manager in [\"crio\", \"containerd\"]"
          "calico_cni_config is defined")))))
