(playbook "kubespray/roles/network_plugin/calico/rr/defaults/main.yml"
  (global_as_num "64512")
  (calico_baremetal_nodename (jinja "{{ kube_override_hostname | default(inventory_hostname) }}")))
