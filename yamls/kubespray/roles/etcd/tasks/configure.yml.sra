(playbook "kubespray/roles/etcd/tasks/configure.yml"
  (tasks
    (task "Configure | Check if etcd cluster is healthy"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster status && " (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster health  2>&1 | grep -v 'Error: unhealthy cluster' >/dev/null")
      (args 
        (executable "/bin/bash"))
      (register "etcd_cluster_is_healthy")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false")
      (run_once "true")
      (when (list
          "('etcd' in group_names)"
          "etcd_cluster_setup"))
      (tags (list
          "facts"))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))))
    (task "Configure | Check if etcd-events cluster is healthy"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster status && " (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster health  2>&1 | grep -v 'Error: unhealthy cluster' >/dev/null")
      (args 
        (executable "/bin/bash"))
      (register "etcd_events_cluster_is_healthy")
      (failed_when "false")
      (changed_when "false")
      (check_mode "false")
      (run_once "true")
      (when (list
          "('etcd' in group_names)"
          "etcd_events_cluster_setup"))
      (tags (list
          "facts"))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_events_access_addresses }}"))))
    (task "Configure | Refresh etcd config"
      (include_tasks "refresh_config.yml")
      (when "('etcd' in group_names)"))
    (task "Configure | Copy etcd.service systemd file"
      (template 
        (src "etcd-" (jinja "{{ etcd_deployment_type }}") ".service.j2")
        (dest "/etc/systemd/system/etcd.service")
        (backup "true")
        (mode "0644")
        (validate "sh -c '[ -f /usr/bin/systemd/system/factory-reset.target ] || exit 0 && systemd-analyze verify %s:etcd-" (jinja "{{ etcd_deployment_type }}") ".service'"))
      (when (list
          "('etcd' in group_names)"
          "etcd_cluster_setup")))
    (task "Configure | Copy etcd-events.service systemd file"
      (template 
        (src "etcd-events-" (jinja "{{ etcd_deployment_type }}") ".service.j2")
        (dest "/etc/systemd/system/etcd-events.service")
        (backup "true")
        (mode "0644")
        (validate "sh -c '[ -f /usr/bin/systemd/system/factory-reset.target ] || exit 0 && systemd-analyze verify %s:etcd-events-" (jinja "{{ etcd_deployment_type }}") ".service'"))
      (when (list
          "('etcd' in group_names)"
          "etcd_events_cluster_setup")))
    (task "Configure | reload systemd"
      (systemd_service 
        (daemon_reload "true"))
      (when "('etcd' in group_names)"))
    (task "Configure | Ensure etcd is running"
      (service 
        (name "etcd")
        (state "started")
        (enabled "true"))
      (ignore_errors (jinja "{{ etcd_cluster_is_healthy.rc == 0 }}"))
      (when (list
          "('etcd' in group_names)"
          "etcd_cluster_setup")))
    (task "Configure | Ensure etcd-events is running"
      (service 
        (name "etcd-events")
        (state "started")
        (enabled "true"))
      (ignore_errors (jinja "{{ etcd_events_cluster_is_healthy.rc != 0 }}"))
      (when (list
          "('etcd' in group_names)"
          "etcd_events_cluster_setup")))
    (task "Configure | Wait for etcd cluster to be healthy"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster status && " (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster health 2>&1 | grep -v 'Error: unhealthy cluster' >/dev/null")
      (args 
        (executable "/bin/bash"))
      (register "etcd_cluster_is_healthy")
      (until "etcd_cluster_is_healthy.rc == 0")
      (retries (jinja "{{ etcd_retries }}"))
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (changed_when "false")
      (check_mode "false")
      (run_once "true")
      (when (list
          "('etcd' in group_names)"
          "etcd_cluster_setup"))
      (tags (list
          "facts"))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))))
    (task "Configure | Wait for etcd-events cluster to be healthy"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster status && " (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster health 2>&1 | grep -v 'Error: unhealthy cluster' >/dev/null")
      (args 
        (executable "/bin/bash"))
      (register "etcd_events_cluster_is_healthy")
      (until "etcd_events_cluster_is_healthy.rc == 0")
      (retries (jinja "{{ etcd_retries }}"))
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (changed_when "false")
      (check_mode "false")
      (run_once "true")
      (when (list
          "('etcd' in group_names)"
          "etcd_events_cluster_setup"))
      (tags (list
          "facts"))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_events_access_addresses }}"))))
    (task "Configure | Check if member is in etcd cluster"
      (shell (jinja "{{ bin_dir }}") "/etcdctl member list | grep -w -q " (jinja "{{ etcd_access_address | replace('[', '') | replace(']', '') }}"))
      (register "etcd_member_in_cluster")
      (ignore_errors "true")
      (changed_when "false")
      (check_mode "false")
      (when (list
          "('etcd' in group_names)"
          "etcd_cluster_setup"))
      (tags (list
          "facts"))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))))
    (task "Configure | Check if member is in etcd-events cluster"
      (shell (jinja "{{ bin_dir }}") "/etcdctl member list | grep -w -q " (jinja "{{ etcd_access_address | replace('[', '') | replace(']', '') }}"))
      (register "etcd_events_member_in_cluster")
      (ignore_errors "true")
      (changed_when "false")
      (check_mode "false")
      (when (list
          "('etcd' in group_names)"
          "etcd_events_cluster_setup"))
      (tags (list
          "facts"))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_events_access_addresses }}"))))
    (task "Configure | Join member(s) to etcd cluster one at a time"
      (include_tasks "join_etcd_member.yml")
      (with_items (jinja "{{ groups['etcd'] }}"))
      (when "inventory_hostname == item and etcd_cluster_setup and etcd_member_in_cluster.rc != 0 and etcd_cluster_is_healthy.rc == 0"))
    (task "Configure | Join member(s) to etcd-events cluster one at a time"
      (include_tasks "join_etcd-events_member.yml")
      (with_items (jinja "{{ groups['etcd'] }}"))
      (when "inventory_hostname == item and etcd_events_cluster_setup and etcd_events_member_in_cluster.rc != 0 and etcd_events_cluster_is_healthy.rc == 0"))))
