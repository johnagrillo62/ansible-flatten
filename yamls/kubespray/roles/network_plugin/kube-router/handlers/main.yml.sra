(playbook "kubespray/roles/network_plugin/kube-router/handlers/main.yml"
  (tasks
    (task "Kube-router | delete kube-router docker containers"
      (shell "set -o pipefail && " (jinja "{{ docker_bin_dir }}") "/docker ps -af name=k8s_POD_kube-router* -q | xargs --no-run-if-empty docker rm -f")
      (listen "Reset_kube_router")
      (args 
        (executable "/bin/bash"))
      (register "docker_kube_router_remove")
      (until "docker_kube_router_remove is succeeded")
      (retries "5")
      (when "container_manager in [\"docker\"]"))
    (task "Kube-router | delete kube-router crio/containerd containers"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl pods --name kube-router* -q | xargs -I% --no-run-if-empty bash -c \"" (jinja "{{ bin_dir }}") "/crictl stopp % && " (jinja "{{ bin_dir }}") "/crictl rmp %\"")
      (listen "Reset_kube_router")
      (args 
        (executable "/bin/bash"))
      (register "crictl_kube_router_remove")
      (until "crictl_kube_router_remove is succeeded")
      (retries "5")
      (when "container_manager in [\"crio\", \"containerd\"]"))))
