(playbook "ansible-galaxy/tasks/virtualenv.yml"
  (tasks
    (task "Create Galaxy virtualenv"
      (pip 
        (name "pip")
        (virtualenv (jinja "{{ galaxy_venv_dir }}"))
        (extra_args (jinja "{{ pip_extra_args | default(omit) }}"))
        (virtualenv_command (jinja "{{ galaxy_virtualenv_command | default(pip_virtualenv_command | default(omit)) }}"))
        (virtualenv_python (jinja "{{ galaxy_virtualenv_python | default(omit) }}")))
      (environment 
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}"))))
    (task "Ensure pip is the desired release"
      (pip 
        (name (list
            "pip"))
        (state (jinja "{{ galaxy_pip_version | default('latest') }}"))
        (extra_args (jinja "{{ pip_extra_args | default('') }}"))
        (virtualenv (jinja "{{ galaxy_venv_dir }}"))
        (virtualenv_command (jinja "{{ galaxy_virtualenv_command | default(pip_virtualenv_command | default(omit)) }}")))
      (environment 
        (PYTHONPATH null)
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}"))))))
