(playbook "ansible-galaxy/tasks/existing.yml"
  (tasks
    (task "Manage an existing Galaxy folder"
      (block (list
          
          (name "Check for Galaxy server directory")
          (stat 
            (path (jinja "{{ galaxy_server_dir }}")))
          (register "existing_dir_present")
          
          (name "Ensure that existing dir is present")
          (assert 
            (that (list
                "existing_dir_present.stat.exists"))
            (fail_msg "Specified existing Galaxy dir: " (jinja "{{ galaxy_server_dir }}") " not found."))
          
          (name "Include virtualenv setup tasks")
          (import_tasks "virtualenv.yml")
          
          (name "Remove orphaned .pyc files and compile bytecode")
          (import_tasks "compile.yml")))
      (remote_user (jinja "{{ galaxy_remote_users.privsep | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.privsep is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.privsep | default(__galaxy_become_user) }}")))))
