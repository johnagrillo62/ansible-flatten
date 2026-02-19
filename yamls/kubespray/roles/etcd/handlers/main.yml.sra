(playbook "kubespray/roles/etcd/handlers/main.yml"
  (tasks
    (task "Backup etcd"
      (import_tasks "backup.yml"))
    (task "Restart etcd"
      (systemd_service 
        (name "etcd")
        (state "restarted")
        (daemon_reload "true"))
      (throttle (jinja "{{ groups['etcd'] | length // 2 }}"))
      (when "('etcd' in group_names)"))
    (task "Restart etcd-events"
      (systemd_service 
        (name "etcd-events")
        (state "restarted")
        (daemon_reload "true"))
      (throttle (jinja "{{ groups['etcd'] | length // 2 }}"))
      (when "('etcd' in group_names)"))
    (task "Wait for etcd up"
      (uri 
        (url "https://" (jinja "{% if 'etcd' in group_names %}") (jinja "{{ etcd_address | ansible.utils.ipwrap }}") (jinja "{% else %}") "127.0.0.1" (jinja "{% endif %}") ":2379/health")
        (validate_certs "false")
        (client_cert (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ inventory_hostname }}") ".pem")
        (client_key (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ inventory_hostname }}") "-key.pem"))
      (listen "Restart etcd")
      (register "result")
      (until "result.status is defined and result.status == 200")
      (retries "60")
      (delay "1"))
    (task "Cleanup etcd backups"
      (import_tasks "backup_cleanup.yml"))
    (task "Wait for etcd-events up"
      (uri 
        (url "https://" (jinja "{% if 'etcd' in group_names %}") (jinja "{{ etcd_address | ansible.utils.ipwrap }}") (jinja "{% else %}") "127.0.0.1" (jinja "{% endif %}") ":2383/health")
        (validate_certs "false")
        (client_cert (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ inventory_hostname }}") ".pem")
        (client_key (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ inventory_hostname }}") "-key.pem"))
      (listen "Restart etcd-events")
      (register "result")
      (until "result.status is defined and result.status == 200")
      (retries "60")
      (delay "1"))
    (task "Set etcd_secret_changed"
      (set_fact 
        (etcd_secret_changed "true")))))
