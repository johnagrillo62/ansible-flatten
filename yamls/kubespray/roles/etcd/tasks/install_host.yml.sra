(playbook "kubespray/roles/etcd/tasks/install_host.yml"
  (tasks
    (task "Get currently-deployed etcd version"
      (command (jinja "{{ bin_dir }}") "/etcd --version")
      (register "etcd_current_host_version")
      (ignore_errors "true")
      (when "etcd_cluster_setup"))
    (task "Restart etcd if necessary"
      (command "/bin/true")
      (notify "Restart etcd")
      (when (list
          "etcd_cluster_setup"
          "etcd_version not in etcd_current_host_version.stdout | default('')")))
    (task "Restart etcd-events if necessary"
      (command "/bin/true")
      (notify "Restart etcd-events")
      (when (list
          "etcd_events_cluster_setup"
          "etcd_version not in etcd_current_host_version.stdout | default('')")))
    (task "Get currently-deployed etcd version as x.y.z format"
      (set_fact 
        (etcd_current_version (jinja "{{ (etcd_current_host_version.stdout | regex_search('etcd Version: ([0-9]+\\\\.[0-9]+\\\\.[0-9]+)', '\\\\1'))[0] | default('') }}")))
      (when "etcd_cluster_setup"))
    (task "Cleanup v2 store data"
      (import_tasks "clean_v2_store.yml"))
    (task "Install | Copy etcd binary from download dir"
      (copy 
        (src (jinja "{{ local_release_dir }}") "/etcd-v" (jinja "{{ etcd_version }}") "-linux-" (jinja "{{ host_architecture }}") "/" (jinja "{{ item }}"))
        (dest (jinja "{{ bin_dir }}") "/" (jinja "{{ item }}"))
        (mode "0755")
        (remote_src "true"))
      (with_items (list
          "etcd"))
      (when "etcd_cluster_setup"))))
