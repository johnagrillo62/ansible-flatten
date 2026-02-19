(playbook "kubespray/tests/testcases/roles/cluster-dump/tasks/main.yml"
  (tasks
    (task "Generate dump folder"
      (command (jinja "{{ bin_dir }}") "/kubectl cluster-info dump --all-namespaces --output-directory /tmp/cluster-dump")
      (when "inventory_hostname in groups['kube_control_plane']"))
    (task "Compress directory cluster-dump"
      (community.general.archive 
        (path "/tmp/cluster-dump")
        (dest "/tmp/cluster-dump.tgz")
        (mode "0644"))
      (when "inventory_hostname in groups['kube_control_plane']"))
    (task "Fetch dump file"
      (fetch 
        (src "/tmp/cluster-dump.tgz")
        (dest (jinja "{{ lookup('env', 'CI_PROJECT_DIR') }}") "/cluster-dump/" (jinja "{{ inventory_hostname }}") ".tgz")
        (flat "true"))
      (when "inventory_hostname in groups['kube_control_plane']"))))
