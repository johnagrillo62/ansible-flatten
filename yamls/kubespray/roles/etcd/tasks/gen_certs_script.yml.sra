(playbook "kubespray/roles/etcd/tasks/gen_certs_script.yml"
  (tasks
    (task "Gen_certs | create etcd cert dir"
      (file 
        (path (jinja "{{ etcd_cert_dir }}"))
        (group (jinja "{{ etcd_cert_group }}"))
        (state "directory")
        (owner (jinja "{{ etcd_owner }}"))
        (mode "0700")))
    (task "Gen_certs | create etcd script dir (on " (jinja "{{ groups['etcd'][0] }}") ")"
      (file 
        (path (jinja "{{ etcd_script_dir }}"))
        (state "directory")
        (owner "root")
        (mode "0700"))
      (run_once "true")
      (when "inventory_hostname == groups['etcd'][0]"))
    (task "Gen_certs | write openssl config"
      (template 
        (src "openssl.conf.j2")
        (dest (jinja "{{ etcd_config_dir }}") "/openssl.conf")
        (mode "0640"))
      (run_once "true")
      (delegate_to (jinja "{{ groups['etcd'][0] }}"))
      (when (list
          "gen_certs | default(false)"
          "inventory_hostname == groups['etcd'][0]")))
    (task "Gen_certs | copy certs generation script"
      (template 
        (src "make-ssl-etcd.sh.j2")
        (dest (jinja "{{ etcd_script_dir }}") "/make-ssl-etcd.sh")
        (mode "0700"))
      (run_once "true")
      (when (list
          "inventory_hostname == groups['etcd'][0]")))
    (task "Gen_certs | run cert generation script for etcd and kube control plane nodes"
      (command "bash -x " (jinja "{{ etcd_script_dir }}") "/make-ssl-etcd.sh -f " (jinja "{{ etcd_config_dir }}") "/openssl.conf -d " (jinja "{{ etcd_cert_dir }}"))
      (environment 
        (MASTERS (jinja "{{ groups['gen_master_certs_True'] | ansible.builtin.intersect(groups['etcd']) | join(' ') }}"))
        (HOSTS (jinja "{{ groups['gen_node_certs_True'] | ansible.builtin.intersect(groups['kube_control_plane']) | join(' ') }}")))
      (run_once "true")
      (delegate_to (jinja "{{ groups['etcd'][0] }}"))
      (when "gen_certs | default(false)")
      (notify "Set etcd_secret_changed"))
    (task "Gen_certs | run cert generation script for all clients"
      (command "bash -x " (jinja "{{ etcd_script_dir }}") "/make-ssl-etcd.sh -f " (jinja "{{ etcd_config_dir }}") "/openssl.conf -d " (jinja "{{ etcd_cert_dir }}"))
      (environment 
        (HOSTS (jinja "{{ groups['gen_node_certs_True'] | ansible.builtin.intersect(groups['k8s_cluster']) | join(' ') }}")))
      (run_once "true")
      (delegate_to (jinja "{{ groups['etcd'][0] }}"))
      (when (list
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""
          "gen_certs | default(false)"))
      (notify "Set etcd_secret_changed"))
    (task "Gen_certs | Gather etcd member/admin and kube_control_plane client certs from first etcd node"
      (slurp 
        (src (jinja "{{ item }}")))
      (register "etcd_master_certs")
      (with_items (list
          (jinja "{{ etcd_cert_dir }}") "/ca.pem"
          (jinja "{{ etcd_cert_dir }}") "/ca-key.pem"
          "[" (jinja "{% for node in groups['etcd'] %}") " '" (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ node }}") ".pem', '" (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ node }}") "-key.pem', '" (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ node }}") ".pem', '" (jinja "{{ etcd_cert_dir }}") "/member-" (jinja "{{ node }}") "-key.pem', " (jinja "{% endfor %}") "]"
          "[" (jinja "{% for node in (groups['kube_control_plane']) %}") " '" (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ node }}") ".pem', '" (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ node }}") "-key.pem', " (jinja "{% endfor %}") "]"))
      (delegate_to (jinja "{{ groups['etcd'][0] }}"))
      (when (list
          "('etcd' in group_names)"
          "sync_certs | default(false)"
          "inventory_hostname != groups['etcd'][0]"))
      (notify "Set etcd_secret_changed"))
    (task "Gen_certs | Write etcd member/admin and kube_control_plane client certs to other etcd nodes"
      (copy 
        (dest (jinja "{{ item.item }}"))
        (content (jinja "{{ item.content | b64decode }}"))
        (group (jinja "{{ etcd_cert_group }}"))
        (owner (jinja "{{ etcd_owner }}"))
        (mode "0640"))
      (with_items (jinja "{{ etcd_master_certs.results }}"))
      (when (list
          "('etcd' in group_names)"
          "sync_certs | default(false)"
          "inventory_hostname != groups['etcd'][0]"))
      (loop_control 
        (label (jinja "{{ item.item }}"))))
    (task "Gen_certs | Gather node certs from first etcd node"
      (slurp 
        (src (jinja "{{ item }}")))
      (register "etcd_master_node_certs")
      (with_items (list
          "[" (jinja "{% for node in groups['k8s_cluster'] %}") " '" (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ node }}") ".pem', '" (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ node }}") "-key.pem', " (jinja "{% endfor %}") "]"))
      (delegate_to (jinja "{{ groups['etcd'][0] }}"))
      (when (list
          "('etcd' in group_names)"
          "inventory_hostname != groups['etcd'][0]"
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""))
      (notify "Set etcd_secret_changed"))
    (task "Gen_certs | Write node certs to other etcd nodes"
      (copy 
        (dest (jinja "{{ item.item }}"))
        (content (jinja "{{ item.content | b64decode }}"))
        (group (jinja "{{ etcd_cert_group }}"))
        (owner (jinja "{{ etcd_owner }}"))
        (mode "0640"))
      (with_items (jinja "{{ etcd_master_node_certs.results }}"))
      (when (list
          "('etcd' in group_names)"
          "inventory_hostname != groups['etcd'][0]"
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""))
      (loop_control 
        (label (jinja "{{ item.item }}"))))
    (task "Gen_certs | Generate etcd certs"
      (include_tasks "gen_nodes_certs_script.yml")
      (when (list
          "('kube_control_plane' in group_names) and sync_certs | default(false) and inventory_hostname not in groups['etcd']")))
    (task "Gen_certs | Generate etcd certs on nodes if needed"
      (include_tasks "gen_nodes_certs_script.yml")
      (when (list
          "kube_network_plugin in [\"calico\", \"flannel\", \"cilium\"] or cilium_deploy_additionally"
          "kube_network_plugin != \"calico\" or calico_datastore == \"etcd\""
          "('k8s_cluster' in group_names) and sync_certs | default(false) and inventory_hostname not in groups['etcd']")))
    (task "Gen_certs | Pretend all control plane have all certs (with symlinks)"
      (file 
        (state "link")
        (src (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ inventory_hostname }}") (jinja "{{ item[0] }}") ".pem")
        (dest (jinja "{{ etcd_cert_dir }}") "/node-" (jinja "{{ item[1] }}") (jinja "{{ item[0] }}") ".pem")
        (mode "0640"))
      (loop (jinja "{{ suffixes | product(groups['kube_control_plane']) }}"))
      (vars 
        (suffixes (list
            ""
            "-key")))
      (when (list
          "('kube_control_plane' in group_names)"
          "item[1] != inventory_hostname"))
      (register "symlink_created")
      (failed_when (list
          "symlink_created is failed"
          "('refusing to convert from file to symlink' not in symlink_created.msg)")))))
