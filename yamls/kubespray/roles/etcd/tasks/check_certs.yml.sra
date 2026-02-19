(playbook "kubespray/roles/etcd/tasks/check_certs.yml"
  (tasks
    (task "Check_certs | Register certs that have already been generated on first etcd node"
      (find 
        (paths (jinja "{{ etcd_cert_dir }}"))
        (patterns "ca.pem,node*.pem,member*.pem,admin*.pem")
        (get_checksum "true"))
      (delegate_to (jinja "{{ groups['etcd'][0] }}"))
      (register "etcdcert_master")
      (run_once "true"))
    (task "Check_certs | Set default value for 'sync_certs', 'gen_certs' and 'etcd_secret_changed' to false"
      (set_fact 
        (sync_certs "false")
        (gen_certs "false")
        (etcd_secret_changed "false")))
    (task "Check certs | Register ca and etcd admin/member certs on etcd hosts"
      (stat 
        (path (jinja "{{ etcd_cert_dir }}") "/" (jinja "{{ item }}"))
        (get_attributes "false")
        (get_checksum "true")
        (get_mime "false"))
      (register "etcd_member_certs")
      (when "('etcd' in group_names)")
      (with_items (list
          "ca.pem"
          "member-" (jinja "{{ inventory_hostname }}") ".pem"
          "member-" (jinja "{{ inventory_hostname }}") "-key.pem"
          "admin-" (jinja "{{ inventory_hostname }}") ".pem"
          "admin-" (jinja "{{ inventory_hostname }}") "-key.pem")))
    (task "Check certs | Register ca and etcd node certs on kubernetes hosts"
      (stat 
        (path (jinja "{{ etcd_cert_dir }}") "/" (jinja "{{ item }}")))
      (register "etcd_node_certs")
      (when "('k8s_cluster' in group_names)")
      (with_items (list
          "ca.pem"
          "node-" (jinja "{{ inventory_hostname }}") ".pem"
          "node-" (jinja "{{ inventory_hostname }}") "-key.pem")))
    (task "Check_certs | Set 'gen_certs' to true if expected certificates are not on the first etcd node(1/2)"
      (set_fact 
        (gen_certs "true"))
      (when "force_etcd_cert_refresh or not item in etcdcert_master.files | map(attribute='path') | list")
      (run_once "true")
      (with_items (jinja "{{ expected_files }}"))
      (vars 
        (expected_files "['" (jinja "{{ etcd_cert_dir }}") "/ca.pem', " (jinja "{% set etcd_members = groups['etcd'] %}") " " (jinja "{% for host in etcd_members %}") "
  '" (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ host }}") ".pem',
  '" (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ host }}") "-key.pem',
  '" (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ host }}") ".pem',
  '" (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ host }}") "-key.pem',
" (jinja "{% endfor %}") " " (jinja "{% set k8s_nodes = groups['kube_control_plane'] %}") " " (jinja "{% for host in k8s_nodes %}") "
  '" (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ host }}") ".pem',
  '" (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ host }}") "-key.pem'
  " (jinja "{% if not loop.last %}") (jinja "{{ ',' }}") (jinja "{% endif %}") "
" (jinja "{% endfor %}") "]")))
    (task "Check_certs | Set 'gen_certs' to true if expected certificates are not on the first etcd node(2/2)"
      (set_fact 
        (gen_certs "true"))
      (run_once "true")
      (with_items (jinja "{{ expected_files }}"))
      (vars 
        (expected_files "['" (jinja "{{ etcd_cert_dir }}") "/ca.pem', " (jinja "{% set etcd_members = groups['etcd'] %}") " " (jinja "{% for host in etcd_members %}") "
  '" (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ host }}") ".pem',
  '" (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ host }}") "-key.pem',
  '" (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ host }}") ".pem',
  '" (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ host }}") "-key.pem',
" (jinja "{% endfor %}") " " (jinja "{% set k8s_nodes = groups['k8s_cluster'] | unique | sort %}") " " (jinja "{% for host in k8s_nodes %}") "
  '" (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ host }}") ".pem',
  '" (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ host }}") "-key.pem'
  " (jinja "{% if not loop.last %}") (jinja "{{ ',' }}") (jinja "{% endif %}") "
" (jinja "{% endfor %}") "]"))
      (when (list
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""
          "force_etcd_cert_refresh or not item in etcdcert_master.files | map(attribute='path') | list")))
    (task "Check_certs | Set 'gen_*_certs' groups to track which nodes needs to have certs generated on first etcd node"
      (ansible.builtin.group_by 
        (key "gen_" (jinja "{{ item.node_type }}") "_certs_" (jinja "{{ force_etcd_cert_refresh or item.certs is not subset(existing_certs) }}")))
      (vars 
        (existing_certs "etcdcert_master.files | map(attribute='path')"))
      (loop (jinja "{{ cert_files | dict2items(key_name='node_type', value_name='certs') }}")))
    (task "Check_certs | Set 'etcd_member_requires_sync' to true if ca or member/admin cert and key don't exist on etcd member or checksum doesn't match"
      (set_fact 
        (etcd_member_requires_sync "true"))
      (when (list
          "('etcd' in group_names)"
          "(not etcd_member_certs.results[0].stat.exists | default(false)) or (not etcd_member_certs.results[1].stat.exists | default(false)) or (not etcd_member_certs.results[2].stat.exists | default(false)) or (not etcd_member_certs.results[3].stat.exists | default(false)) or (not etcd_member_certs.results[4].stat.exists | default(false)) or (etcd_member_certs.results[0].stat.checksum | default('') != etcdcert_master.files | selectattr(\"path\", \"equalto\", etcd_member_certs.results[0].stat.path) | map(attribute=\"checksum\") | first | default('')) or (etcd_member_certs.results[1].stat.checksum | default('') != etcdcert_master.files | selectattr(\"path\", \"equalto\", etcd_member_certs.results[1].stat.path) | map(attribute=\"checksum\") | first | default('')) or (etcd_member_certs.results[2].stat.checksum | default('') != etcdcert_master.files | selectattr(\"path\", \"equalto\", etcd_member_certs.results[2].stat.path) | map(attribute=\"checksum\") | first | default('')) or (etcd_member_certs.results[3].stat.checksum | default('') != etcdcert_master.files | selectattr(\"path\", \"equalto\", etcd_member_certs.results[3].stat.path) | map(attribute=\"checksum\") | first | default('')) or (etcd_member_certs.results[4].stat.checksum | default('') != etcdcert_master.files | selectattr(\"path\", \"equalto\", etcd_member_certs.results[4].stat.path) | map(attribute=\"checksum\") | first | default(''))")))
    (task "Check_certs | Set 'kubernetes_host_requires_sync' to true if ca or node cert and key don't exist on kubernetes host or checksum doesn't match"
      (set_fact 
        (kubernetes_host_requires_sync "true"))
      (when (list
          "('k8s_cluster' in group_names) and inventory_hostname not in groups['etcd']"
          "(not etcd_node_certs.results[0].stat.exists | default(false)) or (not etcd_node_certs.results[1].stat.exists | default(false)) or (not etcd_node_certs.results[2].stat.exists | default(false)) or (etcd_node_certs.results[0].stat.checksum | default('') != etcdcert_master.files | selectattr(\"path\", \"equalto\", etcd_node_certs.results[0].stat.path) | map(attribute=\"checksum\") | first | default('')) or (etcd_node_certs.results[1].stat.checksum | default('') != etcdcert_master.files | selectattr(\"path\", \"equalto\", etcd_node_certs.results[1].stat.path) | map(attribute=\"checksum\") | first | default('')) or (etcd_node_certs.results[2].stat.checksum | default('') != etcdcert_master.files | selectattr(\"path\", \"equalto\", etcd_node_certs.results[2].stat.path) | map(attribute=\"checksum\") | first | default(''))")))
    (task "Check_certs | Set 'sync_certs' to true"
      (set_fact 
        (sync_certs "true"))
      (when (list
          "etcd_member_requires_sync | default(false) or kubernetes_host_requires_sync | default(false) or 'gen_master_certs_True' in group_names or 'gen_node_certs_True' in group_names")))))
