(playbook "ansible-tuto/step-13/roles/apache/tasks/main.yml"
  (tasks
    (task
      (include "apache.yml")
      (tags (list
          "apache")))))
