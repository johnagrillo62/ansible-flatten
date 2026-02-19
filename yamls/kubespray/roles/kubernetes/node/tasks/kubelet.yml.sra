(playbook "kubespray/roles/kubernetes/node/tasks/kubelet.yml"
  (tasks
    (task "Set kubelet api version to v1beta1"
      (set_fact 
        (kubeletConfig_api_version "v1beta1"))
      (tags (list
          "kubelet"
          "kubeadm")))
    (task "Write kubelet environment config file (kubeadm)"
      (template 
        (src "kubelet.env." (jinja "{{ kubeletConfig_api_version }}") ".j2")
        (dest (jinja "{{ kube_config_dir }}") "/kubelet.env")
        (setype (jinja "{{ (preinstall_selinux_state != 'disabled') | ternary('etc_t', omit) }}"))
        (backup "true")
        (mode "0600"))
      (notify "Node | restart kubelet")
      (tags (list
          "kubelet"
          "kubeadm")))
    (task "Write kubelet config file"
      (template 
        (src "kubelet-config." (jinja "{{ kubeletConfig_api_version }}") ".yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/kubelet-config.yaml")
        (mode "0600"))
      (notify "Kubelet | restart kubelet")
      (tags (list
          "kubelet"
          "kubeadm")))
    (task "Write kubelet systemd init file"
      (template 
        (src "kubelet.service.j2")
        (dest "/etc/systemd/system/kubelet.service")
        (backup "true")
        (mode "0600")
        (validate "sh -c '[ -f /usr/bin/systemd/system/factory-reset.target ] || exit 0 && systemd-analyze verify %s:kubelet.service'"))
      (notify "Node | restart kubelet")
      (tags (list
          "kubelet"
          "kubeadm")))
    (task "Flush_handlers and reload-systemd"
      (meta "flush_handlers"))
    (task "Enable kubelet"
      (service 
        (name "kubelet")
        (enabled "true")
        (state "started"))
      (tags (list
          "kubelet"))
      (notify "Kubelet | restart kubelet"))))
