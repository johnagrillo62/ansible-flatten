(playbook "kubespray/roles/network_plugin/cni/tasks/main.yml"
  (tasks
    (task "CNI | make sure /opt/cni/bin exists"
      (file 
        (path "/opt/cni/bin")
        (state "directory")
        (mode "0755")
        (owner (jinja "{{ cni_bin_owner }}"))
        (recurse "true")))
    (task "CNI | Copy cni plugins"
      (unarchive 
        (src (jinja "{{ downloads.cni.dest }}"))
        (dest "/opt/cni/bin")
        (mode "0755")
        (owner (jinja "{{ cni_bin_owner }}"))
        (remote_src "true")))))
