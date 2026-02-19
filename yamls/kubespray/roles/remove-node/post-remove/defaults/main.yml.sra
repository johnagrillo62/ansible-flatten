(playbook "kubespray/roles/remove-node/post-remove/defaults/main.yml"
  (delete_node_retries "10")
  (delete_node_delay_seconds "3"))
