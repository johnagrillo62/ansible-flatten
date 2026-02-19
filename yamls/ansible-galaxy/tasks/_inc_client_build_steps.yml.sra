(playbook "ansible-galaxy/tasks/_inc_client_build_steps.yml"
  (tasks
    (task "Ensure Galaxy version is set"
      (include_tasks "_inc_galaxy_version.yml")
      (when "__galaxy_major_version is undefined"))
    (task "Install packages with yarn"
      (yarn 
        (executable "yarn --network-timeout 300000 --check-files")
        (path (jinja "{{ galaxy_server_dir }}") "/client"))
      (environment 
        (PATH (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
      (when "__galaxy_major_version is version('26.0', '<')"))
    (task "Install packages with pnpm"
      (command "pnpm install")
      (args 
        (chdir (jinja "{{ galaxy_server_dir }}") "/client"))
      (environment 
        (PATH (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
      (when "__galaxy_major_version is version('26.0', '>=')"))
    (task "Ensure deconstructed build is supported"
      (assert 
        (that (list
            "__galaxy_major_version is version('19.09', '>=')"))
        (success_msg "Deconstructed client build is supported")
        (fail_msg "Deconstructed client build is not supported for Galaxy version " (jinja "{{ __galaxy_major_version }}") ", please set 'galaxy_client_make_target'")))
    (task "Run gulp"
      (command "yarn run gulp " (jinja "{{ item }}"))
      (args 
        (chdir (jinja "{{ galaxy_server_dir }}") "/client"))
      (with_items (jinja "{{ galaxy_client_build_steps[__galaxy_major_version] | default(galaxy_client_build_steps.default) }}"))
      (environment 
        (PATH (jinja "{{ galaxy_server_dir }}") "/client/node_modules/.bin:" (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}"))
        (NODE_ENV (jinja "{{ galaxy_client_node_env }}")))
      (when "__galaxy_major_version is version('26.0', '<')"))
    (task "Build plugins"
      (command "pnpm run plugins")
      (args 
        (chdir (jinja "{{ galaxy_server_dir }}") "/client"))
      (environment 
        (PATH (jinja "{{ galaxy_server_dir }}") "/client/node_modules/.bin:" (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}"))
        (NODE_ENV (jinja "{{ galaxy_client_node_env }}")))
      (when "__galaxy_major_version is version('26.0', '>=')"))
    (task "Run webpack"
      (command "yarn run webpack" (jinja "{{ (galaxy_client_node_env == 'production') | ternary('-production', '') }}"))
      (args 
        (chdir (jinja "{{ galaxy_server_dir }}") "/client"))
      (environment 
        (PATH (jinja "{{ galaxy_server_dir }}") "/client/node_modules/.bin:" (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}"))
        (NODE_OPTIONS "--max_old_space_size=8192"))
      (when "__galaxy_major_version is version('26.0', '<')"))
    (task "Run client build"
      (command "pnpm run build-production")
      (args 
        (chdir (jinja "{{ galaxy_server_dir }}") "/client"))
      (environment 
        (PATH (jinja "{{ galaxy_server_dir }}") "/client/node_modules/.bin:" (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}"))
        (NODE_OPTIONS "--max_old_space_size=8192")
        (SKIP_VIZ "1"))
      (when "__galaxy_major_version is version('26.0', '>=')"))
    (task "Stage built client"
      (command "yarn run stage-build")
      (args 
        (chdir (jinja "{{ galaxy_server_dir }}") "/client"))
      (environment 
        (PATH (jinja "{{ galaxy_server_dir }}") "/client/node_modules/.bin:" (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
      (when "__galaxy_major_version is version('23.0', '>=') and __galaxy_major_version is version('26.0', '<')"))))
