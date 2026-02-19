(playbook "kubespray/roles/kubernetes/control-plane/tasks/check-api.yml"
  (tasks
    (task "Kubeadm | Check api is up"
      (uri 
        (url "https://" (jinja "{{ main_ip | ansible.utils.ipwrap }}") ":" (jinja "{{ kube_apiserver_port }}") "/healthz")
        (validate_certs "false"))
      (when "('kube_control_plane' in group_names)")
      (register "_result")
      (retries "60")
      (delay "5")
      (until "_result.status == 200"))))
