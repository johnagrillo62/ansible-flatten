(playbook "kubespray/roles/recover_control_plane/post-recover/tasks/main.yml"
  (tasks
    (task "Set etcd-servers fact"
      (set_fact 
        (etcd_servers (jinja "{% for host in groups['etcd'] -%}") "
  " (jinja "{% if not loop.last -%}") "
  https://" (jinja "{{ hostvars[host]['main_access_ip'] | ansible.utils.ipwrap }}") ":2379,
  " (jinja "{%- endif -%}") "
  " (jinja "{%- if loop.last -%}") "
  https://" (jinja "{{ hostvars[host]['main_access_ip'] | ansible.utils.ipwrap }}") ":2379
  " (jinja "{%- endif -%}") "
" (jinja "{%- endfor -%}"))))
    (task "Update apiserver etcd-servers list"
      (replace 
        (path "/etc/kubernetes/manifests/kube-apiserver.yaml")
        (regexp "(etcd-servers=).*")
        (replace "\\1" (jinja "{{ etcd_servers }}"))))))
