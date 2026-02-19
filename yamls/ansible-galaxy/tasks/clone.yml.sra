(playbook "ansible-galaxy/tasks/clone.yml"
  (tasks
    (task "Clone Galaxy"
      (block (list
          
          (name "Update Galaxy to specified ref")
          (git 
            (dest (jinja "{{ galaxy_server_dir }}"))
            (force (jinja "{{ galaxy_force_checkout }}"))
            (depth (jinja "{{ galaxy_clone_depth | default(omit) }}"))
            (repo (jinja "{{ galaxy_repo }}"))
            (version (jinja "{{ galaxy_commit_id }}"))
            (executable (jinja "{{ git_executable | default(omit) }}")))
          (diff (jinja "{{ galaxy_diff_mode_verbose }}"))
          (register "__galaxy_git_update_result")
          (notify (list
              "restart galaxy"))
          
          (name "Report Galaxy version change")
          (debug 
            (msg "Galaxy version changed from '" (jinja "{{ __galaxy_git_update_result.before }}") "' to '" (jinja "{{ __galaxy_git_update_result.after }}") "'"))
          (changed_when "__galaxy_git_update_result is changed")
          (when "__galaxy_git_update_result is changed")
          
          (name "Include virtualenv setup tasks")
          (import_tasks "virtualenv.yml")
          
          (name "Remove orphaned .pyc files and compile bytecode")
          (import_tasks "compile.yml")
          (when "__galaxy_git_update_result is changed")))
      (remote_user (jinja "{{ galaxy_remote_users.privsep | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.privsep is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.privsep | default(__galaxy_become_user) }}")))))
