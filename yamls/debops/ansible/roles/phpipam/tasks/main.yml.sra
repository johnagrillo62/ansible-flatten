(playbook "debops/ansible/roles/phpipam/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Configure phpIPAM"
      (ansible.builtin.include_tasks "phpipam.yml")
      (when "phpipam__mode is defined and 'webui' in phpipam__mode"))
    (task "Configure phpIPAM scripts"
      (ansible.builtin.include_tasks "phpipam-scripts.yml")
      (when "phpipam__mode is defined and 'scripts' in phpipam__mode"))))
