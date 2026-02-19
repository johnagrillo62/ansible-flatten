(playbook "kubespray/roles/kubernetes/kubeadm_common/tasks/main.yml"
  (tasks
    (task "Kubeadm | Create directory to store kubeadm patches"
      (file 
        (path (jinja "{{ kubeadm_patches_dir }}"))
        (state "directory")
        (mode "0640"))
      (when "kubeadm_patches | length > 0"))
    (task "Kubeadm | Copy kubeadm patches from inventory files"
      (copy 
        (content (jinja "{{ item.patch | to_yaml }}"))
        (dest (jinja "{{ kubeadm_patches_dir }}") "/" (jinja "{{ item.target }}") (jinja "{{ suffix }}") "+" (jinja "{{ item.type | d('strategic') }}") ".yaml")
        (owner "root")
        (mode "0644"))
      (loop (jinja "{{ kubeadm_patches }}"))
      (loop_control 
        (index_var "suffix")))))
