(playbook "kubespray/remove_node.yml"
  (tasks
    (task "Remove node"
      (ansible.builtin.import_playbook "playbooks/remove_node.yml"))))
