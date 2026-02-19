(playbook "ansible-galaxy/tasks/_inc_node_version.yml"
  (tasks
    (task "Determine preferred Node.js version"
      (block (list
          
          (name "Collect Galaxy Node.js version file")
          (slurp 
            (src (jinja "{{ galaxy_server_dir }}") "/client/.node_version"))
          (register "__galaxy_node_version_file")
          
          (name "Set Galaxy Node.js version fact")
          (set_fact 
            (galaxy_node_version (jinja "{{ __galaxy_node_version_file['content'] | b64decode | trim }}")))
          
          (name "Report Node.js version file version")
          (debug 
            (var "galaxy_node_version"))
          
          (name "Override Galaxy Node.js version")
          (set_fact 
            (galaxy_node_version (jinja "{{
  (
   galaxy_node_version_max is version(galaxy_node_version, \"<\")
  ) | ternary(galaxy_node_version_max, galaxy_node_version)
}}")))
          
          (name "Check whether nodeenv is available")
          (stat 
            (path (jinja "{{ galaxy_venv_dir }}") "/bin/nodeenv"))
          (register "nodeenv_availability")
          
          (name "Setup nodeenv if required")
          (block (list
              
              (name "Include virtualenv setup tasks")
              (import_tasks "virtualenv.yml")
              
              (name "Install nodeenv if it doesn't exist")
              (pip 
                (name "nodeenv")
                (virtualenv (jinja "{{ galaxy_venv_dir }}"))
                (extra_args (jinja "{{ pip_extra_args | default('') }}"))
                (virtualenv_command (jinja "{{ galaxy_virtualenv_command | default(pip_virtualenv_command | default(omit)) }}"))
                (virtualenv_python (jinja "{{ galaxy_virtualenv_python | default(omit) }}")))
              (environment 
                (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}")))))
          (when "not nodeenv_availability.stat.exists")))
      (rescue (list
          
          (name "Ensure Galaxy version is set")
          (include_tasks "_inc_galaxy_version.yml")
          (when "__galaxy_major_version is undefined")
          
          (name "Sanity check whether .node_version should be present")
          (assert 
            (that (list
                "__galaxy_major_version is version('19.09', '<')"))
            (fail_msg "Galaxy version " (jinja "{{ __galaxy_major_version }}") " >= 19.09 but client/.node_version file missing!")
            (success_msg "Galaxy version " (jinja "{{ __galaxy_major_version }}") " < 19.09, will use hardcoded Node.js version default"))
          
          (name "Set Galaxy Node.js version fact")
          (set_fact 
            (galaxy_node_version (jinja "{{ '9.11.1' if (__galaxy_major_version is version('19.01', '<')) else '10.13.0' }}"))))))
    (task "Report preferred Node.js version"
      (debug 
        (var "galaxy_node_version")))))
