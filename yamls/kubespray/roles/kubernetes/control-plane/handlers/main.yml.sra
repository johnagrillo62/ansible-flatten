(playbook "kubespray/roles/kubernetes/control-plane/handlers/main.yml"
  (tasks
    (task "Control plane | reload systemd"
      (systemd_service 
        (daemon_reload "true"))
      (listen "Control plane | restart kubelet"))
    (task "Control plane | reload kubelet"
      (service 
        (name "kubelet")
        (state "restarted"))
      (listen "Control plane | restart kubelet"))
    (task "Control plane | Remove apiserver container docker"
      (shell "set -o pipefail && docker ps -af name=k8s_kube-apiserver* -q | xargs --no-run-if-empty docker rm -f")
      (listen "Control plane | Restart apiserver")
      (args 
        (executable "/bin/bash"))
      (register "remove_apiserver_container")
      (retries "10")
      (until "remove_apiserver_container.rc == 0")
      (delay "1")
      (when "container_manager == \"docker\""))
    (task "Control plane | Remove apiserver container containerd/crio"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl pods --name 'kube-apiserver*' -q | xargs -I% --no-run-if-empty bash -c '" (jinja "{{ bin_dir }}") "/crictl stopp % && " (jinja "{{ bin_dir }}") "/crictl rmp %'")
      (listen "Control plane | Restart apiserver")
      (args 
        (executable "/bin/bash"))
      (register "remove_apiserver_container")
      (retries "10")
      (until "remove_apiserver_container.rc == 0")
      (delay "1")
      (when "container_manager in ['containerd', 'crio']"))
    (task "Control plane | Remove scheduler container docker"
      (shell "set -o pipefail && " (jinja "{{ docker_bin_dir }}") "/docker ps -af name=k8s_kube-scheduler* -q | xargs --no-run-if-empty " (jinja "{{ docker_bin_dir }}") "/docker rm -f")
      (listen "Control plane | Restart kube-scheduler")
      (args 
        (executable "/bin/bash"))
      (register "remove_scheduler_container")
      (retries "10")
      (until "remove_scheduler_container.rc == 0")
      (delay "1")
      (when "container_manager == \"docker\""))
    (task "Control plane | Remove scheduler container containerd/crio"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl pods --name 'kube-scheduler*' -q | xargs -I% --no-run-if-empty bash -c '" (jinja "{{ bin_dir }}") "/crictl stopp % && " (jinja "{{ bin_dir }}") "/crictl rmp %'")
      (listen "Control plane | Restart kube-scheduler")
      (args 
        (executable "/bin/bash"))
      (register "remove_scheduler_container")
      (retries "10")
      (until "remove_scheduler_container.rc == 0")
      (delay "1")
      (when "container_manager in ['containerd', 'crio']"))
    (task "Control plane | Remove controller manager container docker"
      (shell "set -o pipefail && " (jinja "{{ docker_bin_dir }}") "/docker ps -af name=k8s_kube-controller-manager* -q | xargs --no-run-if-empty " (jinja "{{ docker_bin_dir }}") "/docker rm -f")
      (listen "Control plane | Restart kube-controller-manager")
      (args 
        (executable "/bin/bash"))
      (register "remove_cm_container")
      (retries "10")
      (until "remove_cm_container.rc == 0")
      (delay "1")
      (when "container_manager == \"docker\""))
    (task "Control plane | Remove controller manager container containerd/crio"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/crictl pods --name 'kube-controller-manager*' -q | xargs -I% --no-run-if-empty bash -c '" (jinja "{{ bin_dir }}") "/crictl stopp % && " (jinja "{{ bin_dir }}") "/crictl rmp %'")
      (listen "Control plane | Restart kube-controller-manager")
      (args 
        (executable "/bin/bash"))
      (register "remove_cm_container")
      (retries "10")
      (until "remove_cm_container.rc == 0")
      (delay "1")
      (when "container_manager in ['containerd', 'crio']"))
    (task "Control plane | wait for kube-scheduler"
      (uri 
        (url "https://" (jinja "{{ endpoint }}") ":10259/healthz")
        (validate_certs "false"))
      (listen (list
          "Control plane | restart kubelet"
          "Control plane | Restart kube-scheduler"))
      (vars 
        (endpoint (jinja "{{ kube_scheduler_bind_address if kube_scheduler_bind_address != '::' else 'localhost' }}")))
      (register "scheduler_result")
      (until "scheduler_result.status == 200")
      (retries (jinja "{{ control_plane_health_retries }}"))
      (delay "1"))
    (task "Control plane | wait for kube-controller-manager"
      (uri 
        (url "https://" (jinja "{{ endpoint }}") ":10257/healthz")
        (validate_certs "false"))
      (listen (list
          "Control plane | restart kubelet"
          "Control plane | Restart kube-controller-manager"))
      (vars 
        (endpoint (jinja "{{ kube_controller_manager_bind_address if kube_controller_manager_bind_address != '::' else 'localhost' }}")))
      (register "controller_manager_result")
      (until "controller_manager_result.status == 200")
      (retries (jinja "{{ control_plane_health_retries }}"))
      (delay "1"))
    (task "Control plane | wait for the apiserver to be running"
      (uri 
        (url (jinja "{{ kube_apiserver_endpoint }}") "/healthz")
        (validate_certs "false"))
      (listen (list
          "Control plane | restart kubelet"
          "Control plane | Restart apiserver"))
      (register "result")
      (until "result.status == 200")
      (retries (jinja "{{ control_plane_health_retries }}"))
      (delay "1"))))
