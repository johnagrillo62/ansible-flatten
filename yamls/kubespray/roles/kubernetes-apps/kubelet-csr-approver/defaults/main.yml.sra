(playbook "kubespray/roles/kubernetes-apps/kubelet-csr-approver/defaults/main.yml"
  (kubelet_csr_approver_enabled (jinja "{{ kubelet_rotate_server_certificates }}"))
  (kubelet_csr_approver_namespace "kube-system")
  (kubelet_csr_approver_repository_name "kubelet-csr-approver")
  (kubelet_csr_approver_repository_url "https://postfinance.github.io/kubelet-csr-approver")
  (kubelet_csr_approver_chart_ref (jinja "{{ kubelet_csr_approver_repository_name }}") "/kubelet-csr-approver")
  (kubelet_csr_approver_chart_version "1.1.0")
  (kubelet_csr_approver_values ))
