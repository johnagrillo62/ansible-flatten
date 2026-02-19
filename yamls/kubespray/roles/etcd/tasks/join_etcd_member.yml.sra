(playbook "kubespray/roles/etcd/tasks/join_etcd_member.yml"
  (tasks
    (task "Join Member | Add member to etcd cluster"
      (command (jinja "{{ bin_dir }}") "/etcdctl member add " (jinja "{{ etcd_member_name }}") " --peer-urls=" (jinja "{{ etcd_peer_url }}"))
      (register "member_add_result")
      (until "member_add_result.rc == 0 or 'Peer URLs already exists' in member_add_result.stderr")
      (failed_when "member_add_result.rc != 0 and 'Peer URLs already exists' not in member_add_result.stderr")
      (retries (jinja "{{ etcd_retries }}"))
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))))
    (task "Join Member | Refresh etcd config"
      (include_tasks "refresh_config.yml")
      (vars 
        (etcd_peer_addresses (jinja "{% for host in groups['etcd'] -%}") "
  " (jinja "{%- if hostvars[host]['etcd_member_in_cluster'].rc == 0 -%}") "
    " (jinja "{{ \"etcd\" + loop.index | string }}") "=https://" (jinja "{{ hostvars[host].etcd_access_address | default(hostvars[host]['main_ip']) | ansible.utils.ipwrap }}") ":2380,
  " (jinja "{%- endif -%}") "
  " (jinja "{%- if loop.last -%}") "
    " (jinja "{{ etcd_member_name }}") "=" (jinja "{{ etcd_peer_url }}") "
  " (jinja "{%- endif -%}") "
" (jinja "{%- endfor -%}"))))
    (task "Join Member | Ensure member is in etcd cluster"
      (shell "set -o pipefail && " (jinja "{{ bin_dir }}") "/etcdctl member list | grep -w " (jinja "{{ etcd_access_address }}") " >/dev/null")
      (args 
        (executable "/bin/bash"))
      (register "etcd_member_in_cluster")
      (changed_when "false")
      (check_mode "false")
      (retries (jinja "{{ etcd_retries }}"))
      (delay (jinja "{{ retry_stagger | random + 3 }}"))
      (until "etcd_member_in_cluster.rc == 0")
      (tags (list
          "facts"))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
        (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
        (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
        (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}"))))
    (task "Configure | Ensure etcd is running"
      (service 
        (name "etcd")
        (state "started")
        (enabled "true")))))
