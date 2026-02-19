(playbook "kubespray/roles/kubernetes/client/defaults/main.yml"
  (kubeconfig_localhost "false")
  (kubeconfig_localhost_ansible_host "false")
  (kubectl_localhost "false")
  (artifacts_dir (jinja "{{ inventory_dir }}") "/artifacts")
  (kube_config_dir "/etc/kubernetes")
  (kube_apiserver_port "6443"))
