(playbook "debops/ansible/roles/tor/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))))
