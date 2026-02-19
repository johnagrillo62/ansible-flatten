(playbook "kubespray/roles/kubernetes-apps/helm/tasks/main.yml"
  (tasks
    (task "Helm | Gather os specific variables"
      (include_vars (jinja "{{ item }}"))
      (with_first_found (list
          
          (files (list
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_release }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") "-" (jinja "{{ ansible_distribution_major_version | lower | replace('/', '_') }}") ".yml"
              (jinja "{{ ansible_distribution | lower }}") ".yml"
              (jinja "{{ ansible_os_family | lower }}") ".yml"
              "defaults.yml"))
          (paths (list
              "../vars"))
          (skip "true"))))
    (task "Helm | Install PyYaml"
      (package 
        (name (jinja "{{ pyyaml_package }}"))
        (state "present"))
      (when "pyyaml_package is defined"))
    (task "Helm | Install PyYaml [flatcar]"
      (include_tasks "pyyaml-flatcar.yml")
      (when "ansible_os_family in [\"Flatcar\", \"Flatcar Container Linux by Kinvolk\"]"))
    (task "Helm | Download helm"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.helm) }}"))))
    (task "Helm | Copy helm binary from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/helm-" (jinja "{{ helm_version }}") "/linux-" (jinja "{{ image_arch }}") "/helm")
        (dest (jinja "{{ bin_dir }}") "/helm")
        (mode "0755")
        (remote_src "true")))
    (task "Helm | Get helm completion"
      (command (jinja "{{ bin_dir }}") "/helm completion bash")
      (changed_when "false")
      (register "helm_completion")
      (check_mode "false"))
    (task "Helm | Install helm completion"
      (copy 
        (dest "/etc/bash_completion.d/helm.sh")
        (content (jinja "{{ helm_completion.stdout }}"))
        (mode "0755"))
      (become "true"))))
