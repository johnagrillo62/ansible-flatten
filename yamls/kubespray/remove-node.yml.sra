(playbook "kubespray/remove-node.yml"
  (tasks
    (task "Remove node"
      (ansible.builtin.import_playbook "playbooks/remove_node.yml"))))
