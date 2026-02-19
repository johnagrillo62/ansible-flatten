(playbook "kubespray/roles/kubespray_defaults/vars/main/main.yml"
  (kube_major_version (jinja "{{ (kube_version | split('.'))[:-1] | join('.') }}"))
  (kube_next (jinja "{{ ((kube_version | split('.'))[1] | int) + 1 }}"))
  (kube_major_next_version "1." (jinja "{{ kube_next }}"))
  (pod_infra_supported_versions 
    (1.35 "3.10.1")
    (1.34 "3.10.1")
    (1.33 "3.10"))
  (etcd_supported_versions 
    (1.35 (jinja "{{ (etcd_binary_checksums['amd64'].keys() | select('version', '3.7', '<'))[0] }}"))
    (1.34 (jinja "{{ (etcd_binary_checksums['amd64'].keys() | select('version', '3.6', '<'))[0] }}"))
    (1.33 (jinja "{{ (etcd_binary_checksums['amd64'].keys() | select('version', '3.6', '<'))[0] }}")))
  (kube_proxy_deployed (jinja "{{ 'addon/kube-proxy' not in kubeadm_init_phases_skip }}"))
  (calico_min_version_required "3.27.0")
  (containerd_min_version_required "1.3.7")
  (kube_service_subnets (jinja "{%- if ipv4_stack and ipv6_stack -%}") " " (jinja "{{ kube_service_addresses }}") "," (jinja "{{ kube_service_addresses_ipv6 }}") " " (jinja "{%- elif ipv4_stack -%}") " " (jinja "{{ kube_service_addresses }}") " " (jinja "{%- else -%}") " " (jinja "{{ kube_service_addresses_ipv6 }}") " " (jinja "{%- endif -%}"))
  (kube_pods_subnets (jinja "{%- if ipv4_stack and ipv6_stack -%}") " " (jinja "{{ kube_pods_subnet }}") "," (jinja "{{ kube_pods_subnet_ipv6 }}") " " (jinja "{%- elif ipv4_stack -%}") " " (jinja "{{ kube_pods_subnet }}") " " (jinja "{%- else -%}") " " (jinja "{{ kube_pods_subnet_ipv6 }}") " " (jinja "{%- endif -%}")))
