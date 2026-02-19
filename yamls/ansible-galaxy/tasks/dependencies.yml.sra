(playbook "ansible-galaxy/tasks/dependencies.yml"
  (tasks
    (task "Manage dependencies"
      (block (list
          
          (name "Include virtualenv setup tasks")
          (import_tasks "virtualenv.yml")
          
          (name "Install Galaxy base dependencies")
          (pip 
            (requirements (jinja "{{ galaxy_requirements_file }}"))
            (extra_args "--index-url https://wheels.galaxyproject.org/simple/ --extra-index-url https://pypi.python.org/simple " (jinja "{{ pip_extra_args | default('') }}"))
            (virtualenv (jinja "{{ galaxy_venv_dir }}"))
            (virtualenv_command (jinja "{{ galaxy_virtualenv_command | default(pip_virtualenv_command | default(omit)) }}")))
          (environment 
            (PYTHONPATH null)
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
          
          (name "Collect Galaxy conditional dependency requirement strings")
          (command (jinja "{{ galaxy_venv_dir }}") "/bin/python -c \"import galaxy.dependencies; print('\\n'.join(galaxy.dependencies.optional('" (jinja "{{ galaxy_config_file }}") "')))\"")
          (environment 
            (PYTHONPATH (jinja "{{ galaxy_server_dir }}") "/lib"))
          (register "conditional_dependencies")
          (changed_when "no")
          
          (name "Install Galaxy conditional dependencies")
          (pip 
            (name (jinja "{{ conditional_dependencies.stdout_lines }}"))
            (extra_args "--index-url https://wheels.galaxyproject.org/simple/ --extra-index-url https://pypi.python.org/simple " (jinja "{{ pip_extra_args | default('') }}"))
            (virtualenv (jinja "{{ galaxy_venv_dir }}"))
            (virtualenv_command (jinja "{{ galaxy_virtualenv_command | default(pip_virtualenv_command | default(omit)) }}")))
          (environment 
            (PYTHONPATH null)
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
          (when "(not ansible_check_mode) and conditional_dependencies.stdout_lines | length > 0")
          
          (name "Install additional packages into galaxy's virtual environment")
          (pip 
            (name (jinja "{{ galaxy_additional_venv_packages }}"))
            (virtualenv (jinja "{{ galaxy_venv_dir }}"))
            (virtualenv_command (jinja "{{ galaxy_virtualenv_command | default(pip_virtualenv_command | default(omit)) }}")))
          (environment 
            (PYTHONPATH null)
            (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))
          (when "galaxy_additional_venv_packages | length > 0")))
      (remote_user (jinja "{{ galaxy_remote_users.privsep | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.privsep is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.privsep | default(__galaxy_become_user) }}")))))
