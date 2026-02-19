(playbook "openshift-ansible/roles/openshift_node/tasks/upgrade.yml"
  (tasks
    (task
      (block (list
          
          (debug 
            (msg "Running openshift_node_pre_cordon_hook " (jinja "{{ openshift_node_pre_cordon_hook }}")))
          
          (include_tasks (jinja "{{ openshift_node_pre_cordon_hook }}"))))
      (when "openshift_node_pre_cordon_hook is defined"))
    (task "Cordon node prior to upgrade"
      (command "oc adm cordon " (jinja "{{ ansible_nodename | lower }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") "
")
      (delegate_to "localhost"))
    (task "Drain node prior to upgrade"
      (command "oc adm drain " (jinja "{{ ansible_nodename | lower }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") " --force --delete-emptydir-data --ignore-daemonsets
")
      (delegate_to "localhost"))
    (task
      (block (list
          
          (debug 
            (msg "Running node openshift_node_pre_upgrade_hook " (jinja "{{ openshift_node_pre_upgrade_hook }}")))
          
          (include_tasks (jinja "{{ openshift_node_pre_upgrade_hook }}"))))
      (when "openshift_node_pre_upgrade_hook is defined"))
    (task "Gather the package facts"
      (ansible.builtin.package_facts 
        (manager "auto")))
    (task "Remove conflicts from openshift-hyperkube"
      (dnf 
        (name "openshift-hyperkube")
        (state "absent"))
      (when (list
          "'openshift-hyperkube' in ansible_facts.packages")))
    (task
      (import_tasks "install.yml"))
    (task
      (import_tasks "apply_machine_config.yml"))
    (task
      (block (list
          
          (debug 
            (msg "Running openshift_node_pre_uncordon_hook " (jinja "{{ openshift_node_pre_uncordon_hook }}")))
          
          (include_tasks (jinja "{{ openshift_node_pre_uncordon_hook }}"))))
      (when "openshift_node_pre_uncordon_hook is defined"))
    (task "Uncordon node after upgrade"
      (command "oc adm uncordon " (jinja "{{ ansible_nodename | lower }}") " --kubeconfig=" (jinja "{{ openshift_node_kubeconfig_path }}") "
")
      (delegate_to "localhost"))
    (task
      (block (list
          
          (debug 
            (msg "Running node openshift_node_post_upgrade_hook " (jinja "{{ openshift_node_post_upgrade_hook }}")))
          
          (include_tasks (jinja "{{ openshift_node_post_upgrade_hook }}"))))
      (when "openshift_node_post_upgrade_hook is defined"))
    (task
      (import_tasks "selinux.yml"))))
