(playbook "kubespray/roles/kubernetes-apps/csi_driver/cinder/tasks/cinder-write-cacert.yml"
  (tasks
    (task "Cinder CSI Driver | Write cacert file"
      (copy 
        (src (jinja "{{ cinder_cacert }}"))
        (dest (jinja "{{ kube_config_dir }}") "/cinder-cacert.pem")
        (group (jinja "{{ kube_cert_group }}"))
        (mode "0640"))
      (delegate_to (jinja "{{ delegate_host_to_write_cacert }}")))))
