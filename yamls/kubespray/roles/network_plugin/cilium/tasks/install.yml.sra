(playbook "kubespray/roles/network_plugin/cilium/tasks/install.yml"
  (tasks
    (task "Cilium | Ensure BPFFS mounted"
      (ansible.posix.mount 
        (fstype "bpf")
        (path "/sys/fs/bpf")
        (src "bpffs")
        (state "mounted")))
    (task "Cilium | Create Cilium certs directory"
      (file 
        (dest (jinja "{{ cilium_cert_dir }}"))
        (state "directory")
        (mode "0750")
        (owner "root")
        (group "root"))
      (when (list
          "cilium_identity_allocation_mode == \"kvstore\"")))
    (task "Cilium | Link etcd certificates for cilium"
      (file 
        (src (jinja "{{ etcd_cert_dir }}") "/" (jinja "{{ item.s }}"))
        (dest (jinja "{{ cilium_cert_dir }}") "/" (jinja "{{ item.d }}"))
        (mode "0644")
        (state "hard")
        (force "true"))
      (loop (list
          
          (s (jinja "{{ kube_etcd_cacert_file }}"))
          (d "ca_cert.crt")
          
          (s (jinja "{{ kube_etcd_cert_file }}"))
          (d "cert.crt")
          
          (s (jinja "{{ kube_etcd_key_file }}"))
          (d "key.pem")))
      (when (list
          "cilium_identity_allocation_mode == \"kvstore\"")))
    (task "Cilium | Render values"
      (template 
        (src "values.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/cilium-values.yaml")
        (mode "0644"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Cilium | Copy extra values"
      (copy 
        (content (jinja "{{ cilium_extra_values | to_nice_yaml(indent=2) }}"))
        (dest (jinja "{{ kube_config_dir }}") "/cilium-extra-values.yaml")
        (mode "0644"))
      (when (list
          "inventory_hostname == groups['kube_control_plane'][0]")))
    (task "Cilium | Copy Ciliumcli binary from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/cilium")
        (dest (jinja "{{ bin_dir }}") "/cilium")
        (mode "0755")
        (remote_src "true")))))
