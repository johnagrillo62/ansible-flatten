(playbook "kubespray/roles/network_plugin/custom_cni/tasks/main.yml"
  (tasks
    (task "Custom CNI | Manifest deployment"
      (block (list
          
          (name "Custom CNI | Check Custom CNI Manifests")
          (assert 
            (that (list
                "custom_cni_manifests | length > 0"))
            (msg "custom_cni_manifests should not be empty"))
          
          (name "Custom CNI | Copy Custom manifests")
          (template 
            (src (jinja "{{ item }}"))
            (dest (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item | basename | replace('.j2', '') }}"))
            (mode "0644"))
          (loop (jinja "{{ custom_cni_manifests }}"))
          (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
          (run_once "true")
          
          (name "Custom CNI | Start Resources")
          (kube 
            (namespace "kube-system")
            (kubectl (jinja "{{ bin_dir }}") "/kubectl")
            (filename (jinja "{{ kube_config_dir }}") "/" (jinja "{{ item | basename | replace('.j2', '') }}"))
            (state "latest")
            (wait "true"))
          (loop (jinja "{{ custom_cni_manifests }}"))
          (delegate_to (jinja "{{ groups['kube_control_plane'] | first }}"))
          (run_once "true")))
      (when "not custom_cni_chart_release_name | length > 0"))))
