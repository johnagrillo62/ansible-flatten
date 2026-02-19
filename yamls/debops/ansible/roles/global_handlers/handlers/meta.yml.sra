(playbook "debops/ansible/roles/global_handlers/handlers/meta.yml"
  (tasks
    (task "Refresh host facts"
      (ansible.builtin.setup null))))
