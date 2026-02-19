(playbook "kubespray/roles/kubernetes/control-plane/tasks/main.yml"
  (tasks
    (task "Pre-upgrade control plane"
      (import_tasks "pre-upgrade.yml")
      (tags (list
          "k8s-pre-upgrade")))
    (task "Create webhook token auth config"
      (template 
        (src "webhook-token-auth-config.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/webhook-token-auth-config.yaml")
        (mode "0640"))
      (when "kube_webhook_token_auth | default(false)"))
    (task "Create webhook authorization config"
      (template 
        (src "webhook-authorization-config.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/webhook-authorization-config.yaml")
        (mode "0640"))
      (when "kube_webhook_authorization | default(false)"))
    (task "Create structured AuthorizationConfiguration file"
      (copy 
        (content (jinja "{{ authz_config | to_nice_yaml(indent=2, sort_keys=false) }}"))
        (dest (jinja "{{ kube_config_dir }}") "/apiserver-authorization-config-" (jinja "{{ kube_apiserver_authorization_config_api_version }}") ".yaml")
        (mode "0640"))
      (vars 
        (authz_config 
          (apiVersion "apiserver.config.k8s.io/" (jinja "{{ kube_apiserver_authorization_config_api_version }}"))
          (kind "AuthorizationConfiguration")
          (authorizers (jinja "{{ kube_apiserver_authorization_config_authorizers }}"))))
      (when "kube_apiserver_use_authorization_config_file"))
    (task "Create kube-scheduler config"
      (template 
        (src "kubescheduler-config.yaml.j2")
        (dest (jinja "{{ kube_config_dir }}") "/kubescheduler-config.yaml")
        (mode "0644")))
    (task "Apply Kubernetes encrypt at rest config"
      (import_tasks "encrypt-at-rest.yml")
      (when (list
          "kube_encrypt_secret_data"))
      (tags (list
          "kube-apiserver")))
    (task "Install | Copy kubectl binary from download dir"
      (copy 
        (src (jinja "{{ downloads.kubectl.dest }}"))
        (dest (jinja "{{ bin_dir }}") "/kubectl")
        (mode "0755")
        (remote_src "true"))
      (tags (list
          "kubectl"
          "upgrade")))
    (task "Install kubectl bash completion"
      (shell (jinja "{{ bin_dir }}") "/kubectl completion bash >/etc/bash_completion.d/kubectl.sh")
      (when "ansible_os_family in [\"Debian\",\"RedHat\", \"Suse\"]")
      (tags (list
          "kubectl"))
      (ignore_errors "true"))
    (task "Set kubectl bash completion file permissions"
      (file 
        (path "/etc/bash_completion.d/kubectl.sh")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "ansible_os_family in [\"Debian\",\"RedHat\", \"Suse\"]")
      (tags (list
          "kubectl"
          "upgrade"))
      (ignore_errors "true"))
    (task "Set bash alias for kubectl"
      (blockinfile 
        (path "/etc/bash_completion.d/kubectl.sh")
        (block "alias " (jinja "{{ kubectl_alias }}") "=kubectl
if [[ $(type -t compopt) = \"builtin\" ]]; then
  complete -o default -F __start_kubectl " (jinja "{{ kubectl_alias }}") "
else
  complete -o default -o nospace -F __start_kubectl " (jinja "{{ kubectl_alias }}") "
fi")
        (state "present")
        (marker "# Ansible entries {mark}"))
      (when (list
          "ansible_os_family in [\"Debian\",\"RedHat\", \"Suse\"]"
          "kubectl_alias is defined and kubectl_alias != \"\""))
      (tags (list
          "kubectl"
          "upgrade"))
      (ignore_errors "true"))
    (task "Include kubeadm setup"
      (import_tasks "kubeadm-setup.yml"))
    (task "Include kubeadm etcd extra tasks"
      (include_tasks "kubeadm-etcd.yml")
      (when "etcd_deployment_type == \"kubeadm\""))
    (task "Cleanup unused AuthorizationConfiguration file versions"
      (file 
        (path (jinja "{{ kube_config_dir }}") "/apiserver-authorization-config-" (jinja "{{ item }}") ".yaml")
        (state "absent"))
      (loop (jinja "{{ ['v1alpha1', 'v1beta1', 'v1'] | reject('equalto', kube_apiserver_authorization_config_api_version) | list }}"))
      (when "kube_apiserver_use_authorization_config_file"))
    (task "Install script to renew K8S control plane certificates"
      (template 
        (src "k8s-certs-renew.sh.j2")
        (dest (jinja "{{ bin_dir }}") "/k8s-certs-renew.sh")
        (mode "0755")))
    (task "Renew K8S control plane certificates monthly 1/2"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/etc/systemd/system/" (jinja "{{ item }}"))
        (mode "0644")
        (validate "sh -c '[ -f /usr/bin/systemd/system/factory-reset.target ] || exit 0 && systemd-analyze verify %s:" (jinja "{{item}}") "'"))
      (with_items (list
          "k8s-certs-renew.service"
          "k8s-certs-renew.timer"))
      (register "k8s_certs_units")
      (when "auto_renew_certificates"))
    (task "Renew K8S control plane certificates monthly 2/2"
      (systemd_service 
        (name "k8s-certs-renew.timer")
        (enabled "true")
        (state "started")
        (daemon_reload (jinja "{{ k8s_certs_units is changed }}")))
      (when "auto_renew_certificates"))))
