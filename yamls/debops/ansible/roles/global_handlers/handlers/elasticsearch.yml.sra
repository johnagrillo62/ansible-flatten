(playbook "debops/ansible/roles/global_handlers/handlers/elasticsearch.yml"
  (tasks
    (task "Start elasticsearch"
      (ansible.builtin.service 
        (name "elasticsearch")
        (state "started")
        (enabled "True")))
    (task "Restart elasticsearch"
      (ansible.builtin.service 
        (name "elasticsearch")
        (state "restarted")))))
