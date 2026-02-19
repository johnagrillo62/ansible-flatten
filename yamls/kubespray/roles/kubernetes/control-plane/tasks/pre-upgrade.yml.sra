(playbook "kubespray/roles/kubernetes/control-plane/tasks/pre-upgrade.yml"
  (tasks
    (task "Pre-upgrade | Delete control plane manifests if etcd secrets changed"
      (file 
        (path "/etc/kubernetes/manifests/" (jinja "{{ item }}") ".manifest")
        (state "absent"))
      (with_items (list
          (list
            "kube-apiserver"
            "kube-controller-manager"
            "kube-scheduler")))
      (register "kube_apiserver_manifest_replaced")
      (when "etcd_secret_changed | default(false)"))
    (task "Pre-upgrade | Delete control plane containers forcefully"
      (shell "set -o pipefail && docker ps -af name=k8s_" (jinja "{{ item }}") "* -q | xargs --no-run-if-empty docker rm -f")
      (args 
        (executable "/bin/bash"))
      (with_items (list
          (list
            "kube-apiserver"
            "kube-controller-manager"
            "kube-scheduler")))
      (when "kube_apiserver_manifest_replaced.changed")
      (register "remove_control_plane_container")
      (retries "10")
      (until "remove_control_plane_container.rc == 0")
      (delay "1"))))
