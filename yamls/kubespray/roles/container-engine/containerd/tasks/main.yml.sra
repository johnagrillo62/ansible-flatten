(playbook "kubespray/roles/container-engine/containerd/tasks/main.yml"
  (tasks
    (task "Containerd | Download containerd"
      (include_tasks "../../../download/tasks/download_file.yml")
      (vars 
        (download (jinja "{{ download_defaults | combine(downloads.containerd) }}"))))
    (task "Containerd | Unpack containerd archive"
      (unarchive 
        (src (jinja "{{ downloads.containerd.dest }}"))
        (dest (jinja "{{ containerd_bin_dir }}"))
        (mode "0755")
        (remote_src "true")
        (extra_opts (list
            "--strip-components=1")))
      (notify "Restart containerd"))
    (task "Containerd | Generate systemd service for containerd"
      (template 
        (src "containerd.service.j2")
        (dest "/etc/systemd/system/containerd.service")
        (mode "0644")
        (validate "sh -c '[ -f /usr/bin/systemd/system/factory-reset.target ] || exit 0 && systemd-analyze verify %s:containerd.service'"))
      (notify "Restart containerd"))
    (task "Containerd | Ensure containerd directories exist"
      (file 
        (dest (jinja "{{ item }}"))
        (state "directory")
        (mode "0755")
        (owner "root")
        (group "root"))
      (with_items (list
          (jinja "{{ containerd_systemd_dir }}")
          (jinja "{{ containerd_cfg_dir }}"))))
    (task "Containerd | Write containerd proxy drop-in"
      (template 
        (src "http-proxy.conf.j2")
        (dest (jinja "{{ containerd_systemd_dir }}") "/http-proxy.conf")
        (mode "0644"))
      (notify "Restart containerd")
      (when "http_proxy is defined or https_proxy is defined"))
    (task "Containerd | Generate default base_runtime_spec"
      (command (jinja "{{ containerd_bin_dir }}") "/ctr oci spec")
      (register "ctr_oci_spec")
      (check_mode "false")
      (changed_when "false"))
    (task "Containerd | Store generated default base_runtime_spec"
      (set_fact 
        (containerd_default_base_runtime_spec (jinja "{{ ctr_oci_spec.stdout | from_json }}"))))
    (task "Containerd | Write base_runtime_specs"
      (copy 
        (content (jinja "{{ item.value }}"))
        (dest (jinja "{{ containerd_cfg_dir }}") "/" (jinja "{{ item.key }}"))
        (owner "root")
        (mode "0644"))
      (with_dict (jinja "{{ containerd_base_runtime_specs | default({}) }}"))
      (notify "Restart containerd"))
    (task "Containerd | Copy containerd config file"
      (template 
        (src (jinja "{{ 'config.toml.j2' if containerd_version is version('2.0.0', '>=') else 'config-v1.toml.j2' }}"))
        (dest (jinja "{{ containerd_cfg_dir }}") "/config.toml")
        (owner "root")
        (mode "0640"))
      (notify "Restart containerd"))
    (task "Containerd | Configure containerd registries"
      (block (list
          
          (name "Containerd | Create registry directories")
          (file 
            (path (jinja "{{ containerd_cfg_dir }}") "/certs.d/" (jinja "{{ item.prefix }}"))
            (state "directory")
            (mode "0755"))
          (loop (jinja "{{ containerd_registries_mirrors }}"))
          
          (name "Containerd | Write hosts.toml file")
          (template 
            (src "hosts.toml.j2")
            (dest (jinja "{{ containerd_cfg_dir }}") "/certs.d/" (jinja "{{ item.prefix }}") "/hosts.toml")
            (mode "0640"))
          (loop (jinja "{{ containerd_registries_mirrors }}"))))
      (no_log (jinja "{{ not (unsafe_show_logs | bool) }}")))
    (task "Containerd | Flush handlers"
      (meta "flush_handlers"))
    (task "Containerd | Ensure containerd is started and enabled"
      (systemd_service 
        (name "containerd")
        (daemon_reload "true")
        (enabled "true")
        (state "started")))))
