(playbook "ansible-galaxy/tasks/_inc_client_install_tools.yml"
  (tasks
    (task "Ensure Galaxy version is set"
      (include_tasks "_inc_galaxy_version.yml")
      (when "__galaxy_major_version is undefined"))
    (task "Enable corepack shims"
      (command "corepack enable --install-directory " (jinja "{{ galaxy_venv_dir }}") "/bin")
      (environment 
        (PATH (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}"))
        (COREPACK_ENABLE_DOWNLOAD_PROMPT "0"))
      (when "__galaxy_major_version is version('25.1', '>=')"))
    (task "Install client build tools"
      (block (list
          
          (name "Ensure galaxy_node_version is set")
          (include_tasks "_inc_node_version.yml")
          (when "galaxy_node_version is undefined")
          
          (name "Check if node is installed")
          (stat 
            (path (jinja "{{ galaxy_venv_dir }}") "/bin/node"))
          (register "__galaxy_node_is_installed")
          
          (name "Collect installed node version")
          (command (jinja "{{ galaxy_venv_dir }}") "/bin/node --version")
          (when "__galaxy_node_is_installed.stat.exists")
          (changed_when "false")
          (register "__galaxy_installed_node_version")
          
          (name "Remove node_modules directory when upgrading node")
          (file 
            (path (jinja "{{ galaxy_venv_dir }}") "/lib/node_modules")
            (state "absent"))
          (when "(not __galaxy_node_is_installed.stat.exists) or (('v' ~ galaxy_node_version) != __galaxy_installed_node_version.stdout)")
          
          (name "Install or upgrade node")
          (command "nodeenv -n " (jinja "{{ galaxy_node_version }}") " -p")
          (environment 
            (PATH (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
          (when "(not __galaxy_node_is_installed.stat.exists) or (('v' ~ galaxy_node_version) != __galaxy_installed_node_version.stdout)")
          
          (name "Install yarn")
          (npm 
            (executable (jinja "{{ galaxy_venv_dir }}") "/bin/npm")
            (name "yarn")
            (global "yes"))
          (environment 
            (PATH (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))))
      (when "__galaxy_major_version is version('25.1', '<')"))))
