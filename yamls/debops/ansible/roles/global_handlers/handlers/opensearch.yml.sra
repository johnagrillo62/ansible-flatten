(playbook "debops/ansible/roles/global_handlers/handlers/opensearch.yml"
  (tasks
    (task "Restart opensearch"
      (ansible.builtin.service 
        (name "opensearch")
        (state "restarted")))))
