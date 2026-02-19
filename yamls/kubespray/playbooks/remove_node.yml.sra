(playbook "kubespray/playbooks/remove_node.yml"
  (tasks
    (task "Validate nodes for removal"
      (hosts "localhost")
      (gather_facts "false")
      (tasks (list
          
          (name "Assert that nodes are specified for removal")
          (assert 
            (that (list
                "node is defined"
                "node | length > 0"))
            (msg "No nodes specified for removal. The `node` variable must be set explicitly."))))
      (become "false"))
    (task "Common tasks for every playbooks"
      (import_playbook "boilerplate.yml"))
    (task "Confirm node removal"
      (hosts (jinja "{{ node | default('this_is_unreachable') }}"))
      (gather_facts "false")
      (tasks (list
          
          (name "Confirm Execution")
          (pause 
            (prompt "Are you sure you want to delete nodes state? Type 'yes' to delete nodes."))
          (register "pause_result")
          (run_once "true")
          (when (list
              "not (skip_confirmation | default(false) | bool)"))
          
          (name "Fail if user does not confirm deletion")
          (fail 
            (msg "Delete nodes confirmation failed"))
          (when "pause_result.user_input | default('yes') != 'yes'"))))
    (task "Gather facts"
      (import_playbook "internal_facts.yml")
      (when "reset_nodes | default(True) | bool"))
    (task "Reset node"
      (hosts (jinja "{{ node | default('this_is_unreachable') }}"))
      (gather_facts "false")
      (pre_tasks (list
          
          (name "Gather information about installed services")
          (service_facts null)
          (when "reset_nodes | default(True) | bool")))
      (roles (list
          
          (role "kubespray_defaults")
          (when "reset_nodes | default(True) | bool")
          
          (role "remove_node/pre_remove")
          (tags "pre-remove")
          
          (role "remove-node/remove-etcd-node")
          (when "'etcd' in group_names")
          
          (role "reset")
          (tags "reset")
          (when "reset_nodes | default(True) | bool")))
      (environment (jinja "{{ proxy_disable_env }}")))
    (task "Post node removal"
      (hosts (jinja "{{ node | default('this_is_unreachable') }}"))
      (gather_facts "false")
      (roles (list
          
          (role "kubespray_defaults")
          (when "reset_nodes | default(True) | bool")
          
          (role "remove-node/post-remove")
          (tags "post-remove")))
      (environment (jinja "{{ proxy_disable_env }}")))))
