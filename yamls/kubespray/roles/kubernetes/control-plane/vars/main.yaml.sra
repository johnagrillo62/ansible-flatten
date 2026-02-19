(playbook "kubespray/roles/kubernetes/control-plane/vars/main.yaml"
  (kube_apiserver_admission_plugins_needs_configuration (list
      "EventRateLimit"
      "ImagePolicyWebhook"
      "PodSecurity"
      "PodNodeSelector"
      "ResourceQuota")))
