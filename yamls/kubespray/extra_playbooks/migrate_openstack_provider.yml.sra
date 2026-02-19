(playbook "kubespray/extra_playbooks/migrate_openstack_provider.yml"
    (play
    (name "Remove old cloud provider config")
    (hosts "kube_node:kube_control_plane")
    (tasks
      (task "Remove old cloud provider config"
        (file 
          (path (jinja "{{ item }}"))
          (state "absent"))
        (with_items (list
            "/etc/kubernetes/cloud_config")))))
    (play
    (name "Migrate intree Cinder PV")
    (hosts "kube_control_plane[0]")
    (tasks
      (task "Include kubespray-default variables"
        (include_vars "../roles/kubespray_defaults/defaults/main/main.yml"))
      (task "Copy get_cinder_pvs.sh to first control plane node"
        (copy 
          (src "get_cinder_pvs.sh")
          (dest "/tmp")
          (mode "u+rwx")))
      (task "Get PVs provisioned by in-tree cloud provider"
        (command "/tmp/get_cinder_pvs.sh")
        (register "pvs"))
      (task "Remove get_cinder_pvs.sh"
        (file 
          (path "/tmp/get_cinder_pvs.sh")
          (state "absent")))
      (task "Rewrite the \"pv.kubernetes.io/provisioned-by\" annotation"
        (command (jinja "{{ bin_dir }}") "/kubectl annotate --overwrite pv " (jinja "{{ item }}") " pv.kubernetes.io/provisioned-by=cinder.csi.openstack.org")
        (loop (jinja "{{ pvs.stdout_lines | list }}"))))))
