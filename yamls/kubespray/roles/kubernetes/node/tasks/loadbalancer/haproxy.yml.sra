(playbook "kubespray/roles/kubernetes/node/tasks/loadbalancer/haproxy.yml"
  (tasks
    (task "Haproxy | Cleanup potentially deployed nginx-proxy"
      (file 
        (path (jinja "{{ kube_manifest_dir }}") "/nginx-proxy.yml")
        (state "absent")))
    (task "Haproxy | Make haproxy directory"
      (file 
        (path (jinja "{{ haproxy_config_dir }}"))
        (state "directory")
        (mode "0755")
        (owner "root")))
    (task "Haproxy | Write haproxy configuration"
      (template 
        (src "loadbalancer/haproxy.cfg.j2")
        (dest (jinja "{{ haproxy_config_dir }}") "/haproxy.cfg")
        (owner "root")
        (mode "0755")
        (backup "true"))
      (register "haproxy_conf"))
    (task "Haproxy | Write static pod"
      (template 
        (src "manifests/haproxy.manifest.j2")
        (dest (jinja "{{ kube_manifest_dir }}") "/haproxy.yml")
        (mode "0640")))))
