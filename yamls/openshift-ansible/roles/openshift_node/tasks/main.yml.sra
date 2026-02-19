(playbook "openshift-ansible/roles/openshift_node/tasks/main.yml"
  (tasks
    (task
      (include_tasks "install.yml"))
    (task
      (include_tasks "config.yml"))))
