(playbook "kubespray/roles/container-engine/molecule/prepare.yml"
    (play
    (name "Prepare")
    (hosts "all")
    (gather_facts "false")
    (become "true")
    (vars
      (ignore_assert_errors "true"))
    (roles
      
        (role "dynamic_groups")
      
        (role "bootstrap_os")
      
        (role "network_facts")
      
        (role "kubernetes/preinstall")
      
        (role "adduser")
        (user (jinja "{{ addusers.kube }}")))
    (tasks
      (task "Download CNI"
        (include_tasks "../../download/tasks/download_file.yml")
        (vars 
          (download (jinja "{{ download_defaults | combine(downloads.cni) }}"))))))
    (play
    (name "Prepare CNI")
    (hosts "all")
    (gather_facts "false")
    (become "true")
    (vars
      (ignore_assert_errors "true")
      (kube_network_plugin "cni"))
    (roles
      
        (role "kubespray_defaults")
      
        (role "network_plugin/cni"))
    (tasks
      (task "Create /etc/cni/net.d directory"
        (file 
          (path "/etc/cni/net.d")
          (state "directory")
          (owner "root")
          (mode "0755")))
      (task "Config bridge host-local CNI"
        (copy 
          (src "10-mynet.conf")
          (dest "/etc/cni/net.d/")
          (owner "root")
          (mode "0644"))))))
