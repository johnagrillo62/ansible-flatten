(playbook "kubespray/tests/files/openeuler24-calico.yml"
  (cloud_image "openeuler-2403")
  (vm_memory "3072")
  (pkg_install_timeout (jinja "{{ 10 * 60 }}"))
  (kubeadm_ignore_preflight_errors (list
      "SystemVerification"))
  (kubelet_fail_cgroup_v1 "false"))
