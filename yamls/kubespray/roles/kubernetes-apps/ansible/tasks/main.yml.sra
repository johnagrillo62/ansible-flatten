(playbook "kubespray/roles/kubernetes-apps/ansible/tasks/main.yml"
  (tasks
    (task "Kubernetes Apps | Wait for kube-apiserver"
      (uri 
        (url (jinja "{{ kube_apiserver_endpoint }}") "/healthz")
        (validate_certs "false")
        (client_cert (jinja "{{ kube_apiserver_client_cert }}"))
        (client_key (jinja "{{ kube_apiserver_client_key }}")))
      (register "result")
      (until "result.status == 200")
      (retries "20")
      (delay "1")
      (when "inventory_hostname == groups['kube_control_plane'][0]"))
    (task "Kubernetes Apps | CoreDNS"
      (command 
        (cmd (jinja "{{ kubectl_apply_stdin }}"))
        (stdin (jinja "{{ lookup('template', item) }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (run_once "true")
      (loop (jinja "{{ coredns_manifests | flatten }}"))
      (tags (list
          "coredns"))
      (vars 
        (clusterIP (jinja "{{ skydns_server }}")))
      (when (list
          "dns_mode in ['coredns', 'coredns_dual']"
          "deploy_coredns")))
    (task "Kubernetes Apps | CoreDNS Secondary"
      (command 
        (cmd (jinja "{{ kubectl_apply_stdin }}"))
        (stdin (jinja "{{ lookup('template', item) }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (run_once "true")
      (loop (jinja "{{ coredns_manifests | flatten }}"))
      (tags (list
          "coredns"))
      (vars 
        (clusterIP (jinja "{{ skydns_server_secondary }}"))
        (coredns_ordinal_suffix "-secondary"))
      (when (list
          "dns_mode == 'coredns_dual'"
          "deploy_coredns")))
    (task "Kubernetes Apps | nodelocalDNS"
      (command 
        (cmd (jinja "{{ kubectl_apply_stdin }}"))
        (stdin (jinja "{{ lookup('template', item) }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (run_once "true")
      (loop (jinja "{{ nodelocaldns_manifests | flatten }}"))
      (when (list
          "enable_nodelocaldns"))
      (tags (list
          "nodelocaldns"
          "coredns"))
      (vars 
        (primaryClusterIP (jinja "{%- if dns_mode in ['coredns', 'coredns_dual'] -%}") " " (jinja "{{ skydns_server }}") " " (jinja "{%- elif dns_mode == 'manual' -%}") " " (jinja "{{ manual_dns_server }}") " " (jinja "{%- endif -%}"))
        (secondaryclusterIP (jinja "{{ skydns_server_secondary }}"))
        (forwardTarget (jinja "{%- if secondaryclusterIP is defined and dns_mode == 'coredns_dual' -%}") " " (jinja "{{ primaryClusterIP }}") " " (jinja "{{ secondaryclusterIP }}") " " (jinja "{%- else -%}") " " (jinja "{{ primaryClusterIP }}") " " (jinja "{%- endif -%}"))
        (upstreamForwardTarget (jinja "{%- if upstream_dns_servers | length > 0 -%}") " " (jinja "{{ upstream_dns_servers | join(' ') }}") " " (jinja "{%- else -%}") " /etc/resolv.conf " (jinja "{%- endif -%}"))))
    (task "Kubernetes Apps | Etcd metrics endpoints"
      (command 
        (cmd (jinja "{{ kubectl_apply_stdin }}"))
        (stdin (jinja "{{ lookup('template', item) }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (run_once "true")
      (loop (list
          "etcd_metrics-endpoints.yml.j2"
          "etcd_metrics-service.yml.j2"))
      (when "etcd_metrics_port is defined and etcd_metrics_service_labels is defined")
      (tags (list
          "etcd_metrics")))
    (task "Kubernetes Apps | Netchecker"
      (command 
        (cmd (jinja "{{ kubectl_apply_stdin }}"))
        (stdin (jinja "{{ lookup('template', item) }}")))
      (delegate_to (jinja "{{ groups['kube_control_plane'][0] }}"))
      (run_once "true")
      (vars 
        (k8s_namespace (jinja "{{ netcheck_namespace }}")))
      (when "deploy_netchecker")
      (tags (list
          "netchecker"))
      (loop (list
          "netchecker-ns.yml.j2"
          "netchecker-agent-sa.yml.j2"
          "netchecker-agent-ds.yml.j2"
          "netchecker-agent-hostnet-ds.yml.j2"
          "netchecker-server-sa.yml.j2"
          "netchecker-server-clusterrole.yml.j2"
          "netchecker-server-clusterrolebinding.yml.j2"
          "netchecker-server-deployment.yml.j2"
          "netchecker-server-svc.yml.j2")))))
