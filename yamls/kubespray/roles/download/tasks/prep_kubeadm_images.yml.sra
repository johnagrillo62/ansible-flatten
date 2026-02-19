(playbook "kubespray/roles/download/tasks/prep_kubeadm_images.yml"
  (tasks
    (task "Prep_kubeadm_images | Download kubeadm binary"
      (include_tasks "download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.kubeadm) }}")))
      (when (list
          "not skip_downloads | default(false)"
          "downloads.kubeadm.enabled")))
    (task "Prep_kubeadm_images | Copy kubeadm binary from download dir to system path"
      (copy 
        (src (jinja "{{ downloads.kubeadm.dest }}"))
        (dest (jinja "{{ bin_dir }}") "/kubeadm")
        (mode "0755")
        (remote_src "true")))
    (task "Prep_kubeadm_images | Create kubeadm config"
      (template 
        (src "kubeadm-images.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/kubeadm-images.yaml")
        (mode "0644")
        (validate (jinja "{{ kubeadm_config_validate_enabled | ternary(bin_dir + '/kubeadm config validate --config %s', omit) }}")))
      (when (list
          "not skip_kubeadm_images | default(false)")))
    (task "Prep_kubeadm_images | Generate list of required images"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/kubeadm config images list --config=" (jinja "{{ kube_config_dir }}") "/kubeadm-images.yaml | grep -Ev 'coredns|pause'")
      (args 
        (executable "/bin/bash"))
      (register "kubeadm_images_raw")
      (run_once "true")
      (changed_when "false")
      (when (list
          "not skip_kubeadm_images | default(false)")))
    (task "Prep_kubeadm_images | Parse list of images"
      (set_fact 
        (kubeadm_image 
          (key "kubeadm_" (jinja "{{ (item | regex_replace('^(?:.*\\\\/)*', '')).split(':')[0] }}"))
          (value 
            (enabled "true")
            (container "true")
            (repo (jinja "{{ item | regex_replace('^(.*):.*$', '\\\\1') }}"))
            (tag (jinja "{{ item | regex_replace('^.*:(.*)$', '\\\\1') }}"))
            (groups (list
                "k8s_cluster")))))
      (vars 
        (kubeadm_images_list (jinja "{{ kubeadm_images_raw.stdout_lines }}")))
      (loop (jinja "{{ kubeadm_images_list | flatten(levels=1) }}"))
      (register "kubeadm_images_cooked")
      (run_once "true")
      (when (list
          "not skip_kubeadm_images | default(false)")))
    (task "Prep_kubeadm_images | Convert list of images to dict for later use"
      (set_fact 
        (kubeadm_images (jinja "{{ kubeadm_images_cooked.results | map(attribute='ansible_facts.kubeadm_image') | list | items2dict }}")))
      (run_once "true")
      (when (list
          "not skip_kubeadm_images | default(false)")))))
