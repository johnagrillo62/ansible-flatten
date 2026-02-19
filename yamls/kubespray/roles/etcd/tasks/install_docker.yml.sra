(playbook "kubespray/roles/etcd/tasks/install_docker.yml"
  (tasks
    (task "Get currently-deployed etcd version"
      (shell (jinja "{{ docker_bin_dir }}") "/docker ps --filter='name=" (jinja "{{ etcd_member_name }}") "' --format='" (jinja "{{ '{{ .Image }}' }}") "'")
      (register "etcd_current_docker_image")
      (when "etcd_cluster_setup"))
    (task "Get currently-deployed etcd-events version"
      (shell (jinja "{{ docker_bin_dir }}") "/docker ps --filter='name=" (jinja "{{ etcd_member_name }}") "-events' --format='" (jinja "{{ '{{ .Image }}' }}") "'")
      (register "etcd_events_current_docker_image")
      (when "etcd_events_cluster_setup"))
    (task "Restart etcd if necessary"
      (command "/bin/true")
      (notify "Restart etcd")
      (when (list
          "etcd_cluster_setup"
          "etcd_image_tag not in etcd_current_docker_image.stdout | default('')")))
    (task "Restart etcd-events if necessary"
      (command "/bin/true")
      (notify "Restart etcd-events")
      (when (list
          "etcd_events_cluster_setup"
          "etcd_image_tag not in etcd_events_current_docker_image.stdout | default('')")))
    (task "Get currently-deployed etcd version as x.y.z format"
      (set_fact 
        (etcd_current_version (jinja "{{ (etcd_current_docker_image.stdout | regex_search('.*:v([0-9]+\\\\.[0-9]+\\\\.[0-9]+)', '\\\\1'))[0] | default('') }}")))
      (when "etcd_cluster_setup"))
    (task "Cleanup v2 store data"
      (import_tasks "clean_v2_store.yml"))
    (task "Install etcd launch script"
      (template 
        (src "etcd.j2")
        (dest (jinja "{{ bin_dir }}") "/etcd")
        (owner "root")
        (mode "0750")
        (backup "true"))
      (when "etcd_cluster_setup"))
    (task "Install etcd-events launch script"
      (template 
        (src "etcd-events.j2")
        (dest (jinja "{{ bin_dir }}") "/etcd-events")
        (owner "root")
        (mode "0750")
        (backup "true"))
      (when "etcd_events_cluster_setup"))))
