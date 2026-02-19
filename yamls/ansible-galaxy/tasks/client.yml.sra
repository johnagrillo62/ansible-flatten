(playbook "ansible-galaxy/tasks/client.yml"
  (tasks
    (task "Build Galaxy client"
      (block (list
          
          (name "Ensure client_build_hash.txt exists")
          (copy 
            (content "new-unbuilt")
            (dest (jinja "{{ galaxy_static_dir }}") "/client_build_hash.txt")
            (mode "0644")
            (force "no"))
          
          (name "Get current client commit id")
          (slurp 
            (src (jinja "{{ galaxy_static_dir }}") "/client_build_hash.txt"))
          (register "__galaxy_client_build_version_result")
          
          (name "Check if Galaxy was checked out from git")
          (stat 
            (path (jinja "{{ galaxy_server_dir }}") "/.git"))
          (register "__galaxy_from_git")
          
          (name "Get current Galaxy commit id")
          (git 
            (dest (jinja "{{ galaxy_server_dir }}"))
            (repo (jinja "{{ galaxy_repo }}"))
            (update "no"))
          (register "__galaxy_git_stat_result")
          (when "__galaxy_from_git.stat.exists")
          
          (name "Set client build version fact")
          (set_fact 
            (__galaxy_client_build_version (jinja "{{ galaxy_client_force_build | ternary('FORCE-BUILD', __galaxy_client_build_version_result.content | b64decode | trim) }}")))
          
          (name "Set galaxy commit ID fact")
          (set_fact 
            (__galaxy_current_commit_id (jinja "{{ __galaxy_git_stat_result.after if __galaxy_from_git.stat.exists else 'none' }}")))
          (when "__galaxy_from_git.stat.exists")
          
          (name "Build Galaxy client if needed")
          (block (list
              
              (name "Report client version mismatch")
              (debug 
                (msg "Galaxy client is out of date: " (jinja "{{ __galaxy_client_build_version }}") " != " (jinja "{{ __galaxy_current_commit_id }}")))
              (changed_when "true")
              (when "__galaxy_from_git.stat.exists")
              
              (name "Include client build tools process")
              (include_tasks "_inc_client_install_tools.yml")
              
              (name "Include client build process")
              (include_tasks "_inc_client_build_" (jinja "{{ 'make' if galaxy_client_make_target is not none else 'steps' }}") ".yml")))
          (when "not __galaxy_from_git.stat.exists or (__galaxy_client_build_version != __galaxy_current_commit_id)")))
      (remote_user (jinja "{{ galaxy_remote_users.privsep | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.privsep is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.privsep | default(__galaxy_become_user) }}"))
      (when "not galaxy_client_use_prebuilt"))
    (task "Install prebuilt client"
      (block (list
          
          (name "Ensure prebuilt client is supported")
          (assert 
            (that (list
                "__galaxy_major_version is version('23.0', '>=')"))
            (success_msg "Prebuilt client is supported")
            (fail_msg "Prebuilt client is not supported for Galaxy version " (jinja "{{ __galaxy_major_version }}") ", '>= 23.0' required."))
          
          (name "Include client install tools process")
          (include_tasks "_inc_client_install_tools.yml")
          
          (name "Install prebuilt client with yarn")
          (yarn 
            (executable "yarn --check-files")
            (path (jinja "{{ galaxy_server_dir }}")))
          (environment 
            (PATH (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
          (register "__yarn_install")
          (changed_when "'already up-to-date' not in __yarn_install.out | lower")
          (when "__galaxy_major_version is version('26.0', '<')")
          
          (name "Install prebuilt client with pnpm")
          (command "pnpm install")
          (args 
            (chdir (jinja "{{ galaxy_server_dir }}")))
          (environment 
            (PATH (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
          (register "__pnpm_install")
          (when "__galaxy_major_version is version('26.0', '>=')")
          
          (name "Stage prebuilt client (yarn)")
          (command "yarn run stage")
          (args 
            (chdir (jinja "{{ galaxy_server_dir }}")))
          (environment 
            (PATH (jinja "{{ galaxy_server_dir }}") "/client/node_modules/.bin:" (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
          (when "__galaxy_major_version is version('26.0', '<') and __yarn_install.changed")
          
          (name "Stage prebuilt client (pnpm)")
          (command "pnpm run stage")
          (args 
            (chdir (jinja "{{ galaxy_server_dir }}")))
          (environment 
            (PATH (jinja "{{ galaxy_server_dir }}") "/client/node_modules/.bin:" (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
          (when "__galaxy_major_version is version('26.0', '>=') and __pnpm_install.changed")))
      (remote_user (jinja "{{ galaxy_remote_users.privsep | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.privsep is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.privsep | default(__galaxy_become_user) }}"))
      (when "galaxy_client_use_prebuilt"))))
