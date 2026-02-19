(playbook "kubespray/roles/network_facts/tasks/no_proxy.yml"
  (tasks
    (task "Set no_proxy to all assigned cluster IPs and hostnames"
      (set_fact 
        (no_proxy_prepare (jinja "{%- if loadbalancer_apiserver is defined -%}") " " (jinja "{{ apiserver_loadbalancer_domain_name }}") ", " (jinja "{{ loadbalancer_apiserver.address | default('') }}") ", " (jinja "{%- endif -%}") " " (jinja "{%- if no_proxy_exclude_workers | default(false) -%}") " " (jinja "{% set cluster_or_control_plane = 'kube_control_plane' %}") " " (jinja "{%- else -%}") " " (jinja "{% set cluster_or_control_plane = 'k8s_cluster' %}") " " (jinja "{%- endif -%}") " " (jinja "{%- for item in (groups[cluster_or_control_plane] + groups['etcd'] | default([]) + groups['calico_rr'] | default([])) | unique -%}") " " (jinja "{{ hostvars[item]['main_access_ip'] }}") ", " (jinja "{%- if item != hostvars[item].get('ansible_hostname', '') -%}") " " (jinja "{{ hostvars[item]['ansible_hostname'] }}") ", " (jinja "{{ hostvars[item]['ansible_hostname'] }}") "." (jinja "{{ dns_domain }}") ", " (jinja "{%- endif -%}") " " (jinja "{{ item }}") "," (jinja "{{ item }}") "." (jinja "{{ dns_domain }}") ", " (jinja "{%- endfor -%}") " " (jinja "{%- if additional_no_proxy is defined -%}") " " (jinja "{{ additional_no_proxy }}") ", " (jinja "{%- endif -%}") " 127.0.0.1,localhost," (jinja "{{ kube_service_subnets }}") "," (jinja "{{ kube_pods_subnets }}") ",svc,svc." (jinja "{{ dns_domain }}")))
      (connection "local")
      (delegate_facts "true")
      (delegate_to "localhost")
      (become "false")
      (run_once "true"))
    (task "Populates no_proxy to all hosts"
      (set_fact 
        (no_proxy (jinja "{{ hostvars.localhost.no_proxy_prepare | select }}"))
        (proxy_env (jinja "{{ proxy_env | combine({
        'no_proxy': hostvars.localhost.no_proxy_prepare,
        'NO_PROXY': hostvars.localhost.no_proxy_prepare
      }) }}"))))))
