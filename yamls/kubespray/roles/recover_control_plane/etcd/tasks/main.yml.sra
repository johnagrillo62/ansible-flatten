(playbook "kubespray/roles/recover_control_plane/etcd/tasks/main.yml"
  (tasks
    (task "Get etcd endpoint health"
      (command (jinja "{{ bin_dir }}") "/etcdctl endpoint health")
      (register "etcd_endpoint_health")
      (ignore_errors "true")
      (changed_when "false")
      (check_mode "false")
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem"))
      (when (list
          "groups['broken_etcd']")))
    (task "Set healthy fact"
      (set_fact 
        (healthy (jinja "{{ etcd_endpoint_health.stderr is match('Error: unhealthy cluster') }}")))
      (when (list
          "groups['broken_etcd']")))
    (task "Set has_quorum fact"
      (set_fact 
        (has_quorum (jinja "{{ etcd_endpoint_health.stdout_lines | select('match', '.*is healthy.*') | list | length >= etcd_endpoint_health.stderr_lines | select('match', '.*is unhealthy.*') | list | length }}")))
      (when (list
          "groups['broken_etcd']")))
    (task "Recover lost etcd quorum"
      (include_tasks "recover_lost_quorum.yml")
      (when (list
          "groups['broken_etcd']"
          "not has_quorum")))
    (task "Remove etcd data dir"
      (file 
        (path (jinja "{{ etcd_data_dir }}"))
        (state "absent"))
      (ignore_unreachable "true")
      (delegate_to (jinja "{{ item }}"))
      (with_items (jinja "{{ groups['broken_etcd'] }}"))
      (ignore_errors "true")
      (when (list
          "groups['broken_etcd']"
          "has_quorum")))
    (task "Delete old certificates"
      (shell "rm " (jinja "{{ etcd_cert_dir }}") "/*" (jinja "{{ item }}") "*")
      (with_items (jinja "{{ groups['broken_etcd'] }}"))
      (register "delete_old_cerificates")
      (ignore_errors "true")
      (when "groups['broken_etcd']"))
    (task "Fail if unable to delete old certificates"
      (fail 
        (msg "Unable to delete old certificates for: " (jinja "{{ item.item }}")))
      (loop (jinja "{{ delete_old_cerificates.results }}"))
      (changed_when "false")
      (when (list
          "groups['broken_etcd']"
          "item.rc != 0 and not 'No such file or directory' in item.stderr")))
    (task "Get etcd cluster members"
      (command (jinja "{{ bin_dir }}") "/etcdctl member list")
      (register "member_list")
      (changed_when "false")
      (check_mode "false")
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem"))
      (when (list
          "groups['broken_etcd']"
          "not healthy"
          "has_quorum")))
    (task "Remove broken cluster members"
      (command (jinja "{{ bin_dir }}") "/etcdctl member remove " (jinja "{{ item[1].replace(' ', '').split(',')[0] }}"))
      (with_nested (list
          (jinja "{{ groups['broken_etcd'] }}")
          (jinja "{{ member_list.stdout_lines }}")))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem"))
      (when (list
          "groups['broken_etcd']"
          "not healthy"
          "has_quorum"
          "hostvars[item[0]]['etcd_member_name'] == item[1].replace(' ', '').split(',')[2]")))))
