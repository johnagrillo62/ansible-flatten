(playbook "openshift-ansible/roles/openshift_node/tasks/selinux.yml"
  (tasks
    (task "Exclude kubelet dir from fixfiles"
      (copy 
        (dest "/etc/selinux/fixfiles_exclude_dirs")
        (content "/var/lib/kubelet")))))
