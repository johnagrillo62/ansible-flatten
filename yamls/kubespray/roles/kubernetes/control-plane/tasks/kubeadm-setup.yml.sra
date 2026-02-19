(playbook "kubespray/roles/kubernetes/control-plane/tasks/kubeadm-setup.yml"
  (tasks
    (task "Install OIDC certificate"
      (copy 
        (content (jinja "{{ kube_oidc_ca_cert | b64decode }}"))
        (dest (jinja "{{ kube_oidc_ca_file }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (when (list
          "kube_oidc_auth"
          "kube_oidc_ca_cert is defined")))
    (task "Kubeadm | Check if kubeadm has already run"
      (stat 
        (path "/var/lib/kubelet/config.yaml")
        (get_attributes "false")
        (get_checksum "false")
        (get_mime "false"))
      (register "kubeadm_already_run"))
    (task "Kubeadm | Backup kubeadm certs / kubeconfig"
      (import_tasks "kubeadm-backup.yml")
      (when (list
          "kubeadm_already_run.stat.exists")))
    (task "Kubeadm | aggregate all SANs"
      (set_fact 
        (apiserver_sans (jinja "{{ _apiserver_sans | flatten | select | unique }}")))
      (vars 
        (_apiserver_sans (list
            "kubernetes"
            "kubernetes.default"
            "kubernetes.default.svc"
            "kubernetes.default.svc." (jinja "{{ dns_domain }}")
            (jinja "{{ kube_apiserver_ip }}")
            "localhost"
            "127.0.0.1"
            "::1"
            (jinja "{{ apiserver_loadbalancer_domain_name | d('') }}")
            (jinja "{{ loadbalancer_apiserver.address | d('') }}")
            (jinja "{{ supplementary_addresses_in_ssl_keys }}")
            (jinja "{{ groups['kube_control_plane'] | map('extract', hostvars, 'main_access_ip') }}")
            (jinja "{{ groups['kube_control_plane'] | map('extract', hostvars, 'main_ip') }}")
            (jinja "{{ groups['kube_control_plane'] | map('extract', hostvars, ['ansible_default_ipv4', 'address']) | select('defined') }}")
            (jinja "{{ groups['kube_control_plane'] | map('extract', hostvars, ['ansible_default_ipv6', 'address']) | select('defined') }}")
            (jinja "{{ groups['kube_control_plane'] | map('extract', hostvars, 'ansible_hostname') }}")
            (jinja "{{ groups['kube_control_plane'] | map('extract', hostvars, 'ansible_fqdn') }}")
            (jinja "{{ kube_override_hostname }}")
            (jinja "{{ kube_vip_address }}"))))
      (tags "facts"))
    (task "Create audit-policy directory"
      (file 
        (path (jinja "{{ audit_policy_file | dirname }}"))
        (state "directory")
        (mode "0640"))
      (when "kubernetes_audit or kubernetes_audit_webhook"))
    (task "Write api audit policy yaml"
      (template 
        (src "apiserver-audit-policy.yaml.j2")
        (dest (jinja "{{ audit_policy_file }}"))
        (mode "0640"))
      (when "kubernetes_audit or kubernetes_audit_webhook")
      (notify "Control plane | Restart apiserver"))
    (task "Write api audit webhook config yaml"
      (template 
        (src "apiserver-audit-webhook-config.yaml.j2")
        (dest (jinja "{{ audit_webhook_config_file }}"))
        (mode "0640"))
      (when "kubernetes_audit_webhook")
      (notify "Control plane | Restart apiserver"))
    (task "Create apiserver tracing config directory"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/tracing")
        (state "directory")
        (mode "0640"))
      (when "kube_apiserver_tracing"))
    (task "Write apiserver tracing config yaml"
      (template 
        (src "apiserver-tracing.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/tracing/apiserver-tracing.yaml")
        (mode "0640"))
      (when "kube_apiserver_tracing")
      (notify "Control plane | Restart apiserver"))
    (task "Set kubeadm_config_api_fqdn define"
      (set_fact 
        (kubeadm_config_api_fqdn (jinja "{{ apiserver_loadbalancer_domain_name }}")))
      (when "loadbalancer_apiserver is defined"))
    (task "Kubeadm | Create kubeadm config"
      (template 
        (src "kubeadm-config." (jinja "{{ kubeadm_config_api_version }}") ".yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml")
        (mode "0640")
        (validate (jinja "{{ kubeadm_config_validate_enabled | ternary(bin_dir + '/kubeadm config validate --config %s', omit) }}"))))
    (task "Kubeadm | Create directory to store admission control configurations"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/admission-controls")
        (state "directory")
        (mode "0640"))
      (when "kube_apiserver_admission_control_config_file"))
    (task "Kubeadm | Push admission control config file"
      (template 
        (src "admission-controls.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/admission-controls/admission-controls.yaml")
        (mode "0640"))
      (when "kube_apiserver_admission_control_config_file")
      (notify "Control plane | Restart apiserver"))
    (task "Kubeadm | Push admission control config files"
      (template 
        (src (jinja "{{ item | lower }}") ".yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/admission-controls/" (jinja "{{ item | lower }}") ".yaml")
        (mode "0640"))
      (when (list
          "kube_apiserver_admission_control_config_file"
          "item in kube_apiserver_admission_plugins_needs_configuration"))
      (loop (jinja "{{ kube_apiserver_enable_admission_plugins }}"))
      (notify "Control plane | Restart apiserver"))
    (task "Kubeadm | Check apiserver.crt SANs"
      (block (list
          
          (name "Kubeadm | Check apiserver.crt SAN IPs")
          (command 
            (cmd "openssl x509 -noout -in " (jinja "{{ kube_cert_dir }}") "/apiserver.crt -checkip " (jinja "{{ item }}")))
          (loop (jinja "{{ apiserver_ips }}"))
          (register "apiserver_sans_ip_check")
          (changed_when "apiserver_sans_ip_check.stdout is not search('does match certificate')")
          (failed_when "apiserver_sans_ip_check.rc != 0 and apiserver_sans_ip_check.stdout is not search('does NOT match certificate')")
          
          (name "Kubeadm | Check apiserver.crt SAN hosts")
          (command 
            (cmd "openssl x509 -noout -in " (jinja "{{ kube_cert_dir }}") "/apiserver.crt -checkhost " (jinja "{{ item }}")))
          (loop (jinja "{{ apiserver_hosts }}"))
          (register "apiserver_sans_host_check")
          (changed_when "apiserver_sans_host_check.stdout is not search('does match certificate')")
          (failed_when "apiserver_sans_host_check.rc != 0 and apiserver_sans_host_check.stdout is not search('does NOT match certificate')")))
      (vars 
        (apiserver_ips (jinja "{{ apiserver_sans | map('ansible.utils.ipaddr') | reject('equalto', False) | list }}"))
        (apiserver_hosts (jinja "{{ apiserver_sans | difference(apiserver_ips) }}")))
      (when (list
          "kubeadm_already_run.stat.exists"
          "not kube_external_ca_mode")))
    (task "Kubeadm | regenerate apiserver cert 1/2"
      (file 
        (state "absent")
        (path (jinja "{{ kube_cert_dir }}") "/" (jinja "{{ item }}")))
      (with_items (list
          "apiserver.crt"
          "apiserver.key"))
      (when (list
          "kubeadm_already_run.stat.exists"
          "apiserver_sans_ip_check.changed or apiserver_sans_host_check.changed"
          "not kube_external_ca_mode")))
    (task "Kubeadm | regenerate apiserver cert 2/2"
      (command (jinja "{{ bin_dir }}") "/kubeadm init phase certs apiserver --config=" (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml")
      (when (list
          "kubeadm_already_run.stat.exists"
          "apiserver_sans_ip_check.changed or apiserver_sans_host_check.changed"
          "not kube_external_ca_mode")))
    (task "Kubeadm | Initialize first control plane node"
      (block (list
          
          (name "Kubeadm | Initialize first control plane node (1st try)")
          (command (jinja "{{ kubeadm_init_first_control_plane_cmd }}"))
          (register "kubeadm_init")
          (failed_when "kubeadm_init.rc != 0 and \"field is immutable\" not in kubeadm_init.stderr")))
      (rescue (list
          
          (name "Kubeadm | Initialize first control plane node (retry)")
          (command (jinja "{{ kubeadm_init_first_control_plane_cmd }}"))
          (vars 
            (_errors_from_first_try (list
                "FileAvailable--etc-kubernetes-manifests-kube-controller-manager.yaml"
                "FileAvailable--etc-kubernetes-manifests-kube-scheduler.yaml"
                "FileAvailable--etc-kubernetes-manifests-kube-apiserver.yaml"
                "Port-10250"))
            (_ignore_errors (list
                (jinja "{{ kubeadm_ignore_preflight_errors }}")
                (jinja "{{ _errors_from_first_try if 'all' not in kubeadm_ignore_preflight_errors else [] }}"))))
          (register "kubeadm_init")
          (retries "2")
          (until "kubeadm_init is succeeded or \"field is immutable\" in kubeadm_init.stderr")
          (failed_when "kubeadm_init.rc != 0 and \"field is immutable\" not in kubeadm_init.stderr")))
      (when "inventory_hostname == first_kube_control_plane and not kubeadm_already_run.stat.exists")
      (vars 
        (kubeadm_init_first_control_plane_cmd "timeout -k " (jinja "{{ kubeadm_init_timeout }}") " " (jinja "{{ kubeadm_init_timeout }}") " " (jinja "{{ bin_dir }}") "/kubeadm init --config=" (jinja "{{ kube_config_dir }}") "/kubeadm-config.yaml --ignore-preflight-errors=" (jinja "{{ _ignore_errors | flatten | join(',') }}") " --skip-phases=" (jinja "{{ kubeadm_init_phases_skip | join(',') }}") " " (jinja "{{ kube_external_ca_mode | ternary('', '--upload-certs') }}"))
        (_ignore_errors (jinja "{{ kubeadm_ignore_preflight_errors }}")))
      (environment 
        (PATH (jinja "{{ bin_dir }}") ":" (jinja "{{ ansible_env.PATH }}")))
      (notify "Control plane | restart kubelet"))
    (task "Set kubeadm certificate key"
      (set_fact 
        (kubeadm_certificate_key (jinja "{{ item | regex_search('--certificate-key ([^ ]+)', '\\\\1') | first }}")))
      (with_items (jinja "{{ hostvars[groups['kube_control_plane'][0]]['kubeadm_init'].stdout_lines | default([]) }}"))
      (when (list
          "kubeadm_certificate_key is not defined"
          "(item | trim) is match('.*--certificate-key.*')")))
    (task "Create hardcoded kubeadm token for joining nodes with 24h expiration (if defined)"
      (shell (jinja "{{ bin_dir }}") "/kubeadm --kubeconfig " (jinja "{{ kube_config_dir }}") "/admin.conf token delete " (jinja "{{ kubeadm_token }}") " || :; " (jinja "{{ bin_dir }}") "/kubeadm --kubeconfig " (jinja "{{ kube_config_dir }}") "/admin.conf token create " (jinja "{{ kubeadm_token }}"))
      (changed_when "false")
      (when (list
          "inventory_hostname == first_kube_control_plane"
          "kubeadm_token is defined"
          "kubeadm_refresh_token"))
      (tags (list
          "kubeadm_token")))
    (task "Remove binding to anonymous user"
      (command (jinja "{{ kubectl }}") " -n kube-public delete rolebinding kubeadm:bootstrap-signer-clusterinfo --ignore-not-found")
      (when "inventory_hostname == first_kube_control_plane and remove_anonymous_access"))
    (task "Create kubeadm token for joining nodes with 24h expiration (default)"
      (command (jinja "{{ bin_dir }}") "/kubeadm --kubeconfig " (jinja "{{ kube_config_dir }}") "/admin.conf token create")
      (changed_when "false")
      (register "temp_token")
      (retries "5")
      (delay "5")
      (until "temp_token is succeeded")
      (delegate_to (jinja "{{ first_kube_control_plane }}"))
      (when "kubeadm_token is not defined")
      (tags (list
          "kubeadm_token")))
    (task "Set kubeadm_token"
      (set_fact 
        (kubeadm_token (jinja "{{ temp_token.stdout }}")))
      (when "temp_token.stdout is defined")
      (tags (list
          "kubeadm_token")))
    (task "Kubeadm | Join other control plane nodes"
      (include_tasks "kubeadm-secondary.yml"))
    (task "Kubeadm | upgrade kubernetes cluster to " (jinja "{{ kube_version }}")
      (include_tasks "kubeadm-upgrade.yml")
      (when (list
          "upgrade_cluster_setup"
          "kubeadm_already_run.stat.exists")))
    (task "Kubeadm | Remove taint for control plane node with node role"
      (command (jinja "{{ kubectl }}") " taint node " (jinja "{{ inventory_hostname }}") " " (jinja "{{ item }}"))
      (delegate_to (jinja "{{ first_kube_control_plane }}"))
      (with_items (list
          "node-role.kubernetes.io/control-plane:NoSchedule-"))
      (when "('kube_node' in group_names)")
      (failed_when "false"))))
