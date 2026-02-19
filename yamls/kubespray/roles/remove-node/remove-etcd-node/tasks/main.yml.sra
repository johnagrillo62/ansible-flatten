(playbook "kubespray/roles/remove-node/remove-etcd-node/tasks/main.yml"
  (tasks
    (task "Remove etcd member from cluster"
      (block (list
          
          (name "Lookup members infos")
          (command (jinja "{{ bin_dir }}") "/etcdctl member list -w json")
          (register "etcd_members")
          (changed_when "false")
          (check_mode "false")
          (tags (list
              "facts"))
          
          (name "Remove member from cluster")
          (command 
            (argv (list
                (jinja "{{ bin_dir }}") "/etcdctl"
                "member"
                "remove"
                (jinja "{{ '%x' | format(etcd_removed_nodes[0].ID) }}"))))
          (vars 
            (etcd_removed_nodes (jinja "{{ (etcd_members.stdout | from_json).members | selectattr('peerURLs.0', '==', etcd_peer_url) }}")))
          (when "etcd_removed_nodes != []")
          (register "etcd_removal_output")
          (changed_when "'Removed member' in etcd_removal_output.stdout")))
      (environment 
        (ETCDCTL_API "3")
        (ETCDCTL_CERT (jinja "{{ kube_cert_dir + '/etcd/server.crt' if etcd_deployment_type == 'kubeadm' else etcd_cert_dir + '/admin-' + groups['etcd'] | first + '.pem' }}"))
        (ETCDCTL_KEY (jinja "{{ kube_cert_dir + '/etcd/server.key' if etcd_deployment_type == 'kubeadm' else etcd_cert_dir + '/admin-' + groups['etcd'] | first + '-key.pem' }}"))
        (ETCDCTL_CACERT (jinja "{{ kube_cert_dir + '/etcd/ca.crt' if etcd_deployment_type == 'kubeadm' else etcd_cert_dir + '/ca.pem' }}"))
        (ETCDCTL_ENDPOINTS "https://127.0.0.1:2379"))
      (delegate_to (jinja "{{ groups['etcd'] | first }}")))))
