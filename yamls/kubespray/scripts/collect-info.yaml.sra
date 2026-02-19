(playbook "kubespray/scripts/collect-info.yaml"
    (play
    (name "Collect debug info")
    (hosts "all")
    (become "true")
    (gather_facts "false")
    (vars
      (docker_bin_dir "/usr/bin")
      (bin_dir "/usr/local/bin")
      (ansible_ssh_pipelining "true")
      (etcd_cert_dir "/etc/ssl/etcd/ssl")
      (kube_network_plugin "calico")
      (archive_dirname "collect-info")
      (commands (list
          
          (name "timedate_info")
          (cmd "timedatectl status")
          
          (name "kernel_info")
          (cmd "uname -r")
          
          (name "docker_info")
          (cmd (jinja "{{ docker_bin_dir }}") "/docker info")
          
          (name "ip_info")
          (cmd "ip -4 -o a")
          
          (name "route_info")
          (cmd "ip ro")
          
          (name "proc_info")
          (cmd "ps auxf | grep -v ]$")
          
          (name "systemctl_failed_info")
          (cmd "systemctl --state=failed --no-pager")
          
          (name "k8s_info")
          (cmd (jinja "{{ bin_dir }}") "/kubectl get all --all-namespaces -o wide")
          
          (name "errors_info")
          (cmd "journalctl -p err --no-pager")
          
          (name "etcd_info")
          (cmd (jinja "{{ bin_dir }}") "/etcdctl endpoint --cluster health")
          
          (name "calico_info")
          (cmd (jinja "{{ bin_dir }}") "/calicoctl node status")
          (when (jinja "{{ kube_network_plugin == \"calico\" }}"))
          
          (name "calico_workload_info")
          (cmd (jinja "{{ bin_dir }}") "/calicoctl get workloadEndpoint -o wide")
          (when (jinja "{{ kube_network_plugin == \"calico\" }}"))
          
          (name "calico_pool_info")
          (cmd (jinja "{{ bin_dir }}") "/calicoctl get ippool -o wide")
          (when (jinja "{{ kube_network_plugin == \"calico\" }}"))
          
          (name "kube_describe_all")
          (cmd (jinja "{{ bin_dir }}") "/kubectl describe all --all-namespaces")
          
          (name "kube_describe_nodes")
          (cmd (jinja "{{ bin_dir }}") "/kubectl describe nodes")
          
          (name "kubelet_logs")
          (cmd "journalctl -u kubelet --no-pager")
          
          (name "coredns_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l k8s-app=coredns -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system; done")
          
          (name "apiserver_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system; done")
          
          (name "controller_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l component=kube-controller-manager -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system; done")
          
          (name "scheduler_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l component=kube-scheduler -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system; done")
          
          (name "proxy_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l k8s-app=kube-proxy -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system; done")
          
          (name "nginx_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l k8s-app=kube-nginx -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system; done")
          
          (name "flannel_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l app=flannel -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system flannel-container; done")
          (when (jinja "{{ kube_network_plugin == \"flannel\" }}"))
          
          (name "canal_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l k8s-app=canal-node -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system flannel; done")
          (when (jinja "{{ kube_network_plugin == \"canal\" }}"))
          
          (name "calico_policy_logs")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/kubectl get pods -n kube-system -l k8s-app=calico-kube-controllers -o jsonpath={.items..metadata.name}`; do " (jinja "{{ bin_dir }}") "/kubectl logs ${i} -n kube-system ; done")
          (when (jinja "{{ kube_network_plugin in [\"canal\", \"calico\"] }}"))
          
          (name "helm_show_releases_history")
          (cmd "for i in `" (jinja "{{ bin_dir }}") "/helm list -q`; do " (jinja "{{ bin_dir }}") "/helm history ${i} --col-width=0; done")
          (when (jinja "{{ helm_enabled | default(true) }}"))))
      (logs (list
          "/var/log/syslog"
          "/var/log/daemon.log"
          "/var/log/kern.log"
          "/var/log/dpkg.log"
          "/var/log/apt/history.log"
          "/var/log/yum.log"
          "/var/log/messages"
          "/var/log/dmesg")))
    (environment
      (ETCDCTL_API "3")
      (ETCDCTL_CERT (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") ".pem")
      (ETCDCTL_KEY (jinja "{{ etcd_cert_dir }}") "/admin-" (jinja "{{ inventory_hostname }}") "-key.pem")
      (ETCDCTL_CACERT (jinja "{{ etcd_cert_dir }}") "/ca.pem")
      (ETCDCTL_ENDPOINTS (jinja "{{ etcd_access_addresses }}")))
    (tasks
      (task "Set etcd_access_addresses"
        (set_fact 
          (etcd_access_addresses (jinja "{% for item in groups['etcd'] -%}") "
  https://" (jinja "{{ item }}") ":2379" (jinja "{% if not loop.last %}") "," (jinja "{% endif %}") "
" (jinja "{%- endfor %}")))
        (when "'etcd' in groups"))
      (task "Storing commands output"
        (shell (jinja "{{ item.cmd }}") " &> " (jinja "{{ item.name }}"))
        (failed_when "false")
        (with_items (jinja "{{ commands }}"))
        (when "item.when | default(True)")
        (no_log "true"))
      (task "Fetch results"
        (fetch 
          (src (jinja "{{ item.name }}"))
          (dest "/tmp/" (jinja "{{ archive_dirname }}") "/commands"))
        (with_items (jinja "{{ commands }}"))
        (when "item.when | default(True)")
        (failed_when "false"))
      (task "Fetch logs"
        (fetch 
          (src (jinja "{{ item }}"))
          (dest "/tmp/" (jinja "{{ archive_dirname }}") "/logs"))
        (with_items (jinja "{{ logs }}"))
        (failed_when "false"))
      (task "Pack results and logs"
        (community.general.archive 
          (path "/tmp/" (jinja "{{ archive_dirname }}"))
          (dest (jinja "{{ dir | default('.') }}") "/logs.tar.gz")
          (remove "true")
          (mode "0640"))
        (connection "local")
        (delegate_to "localhost")
        (become "false")
        (run_once "true"))
      (task "Clean up collected command outputs"
        (file 
          (path (jinja "{{ item.name }}"))
          (state "absent"))
        (with_items (jinja "{{ commands }}"))))))
