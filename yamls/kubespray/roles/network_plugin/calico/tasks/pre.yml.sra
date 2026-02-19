(playbook "kubespray/roles/network_plugin/calico/tasks/pre.yml"
  (tasks
    (task "Slurp CNI config"
      (slurp 
        (src "/etc/cni/net.d/10-calico.conflist"))
      (register "calico_cni_config_slurp")
      (failed_when "false"))
    (task "Gather calico facts"
      (block (list
          
          (name "Set fact calico_cni_config from slurped CNI config")
          (set_fact 
            (calico_cni_config (jinja "{{ calico_cni_config_slurp['content'] | b64decode | from_json }}")))
          
          (name "Set fact calico_datastore to etcd if needed")
          (set_fact 
            (calico_datastore "etcd"))
          (when (list
              "'plugins' in calico_cni_config"
              "'etcd_endpoints' in calico_cni_config.plugins.0"))))
      (tags (list
          "facts"))
      (when "calico_cni_config_slurp.content is defined"))
    (task "Calico | Gather os specific variables"
      (include_vars (jinja "{{ item }}"))
      (with_first_found (list
          
          (files (list
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_release }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_major_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") "-" (jinja "{{ ansible_architecture }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") ".yml"
              "defaults.yml"))
          (paths (list
              "../vars"))
          (skip "true"))))))
