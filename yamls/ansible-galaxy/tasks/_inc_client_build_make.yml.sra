(playbook "ansible-galaxy/tasks/_inc_client_build_make.yml"
  (tasks
    (task "Build client"
      (make 
        (chdir (jinja "{{ galaxy_server_dir }}"))
        (target (jinja "{{ galaxy_client_make_target }}")))
      (environment 
        (PATH (jinja "{{ galaxy_venv_dir }}") "/bin:" (jinja "{{ ansible_env.PATH }}"))
        (VIRTUAL_ENV (jinja "{{ galaxy_venv_dir }}"))
        (COREPACK_ENABLE_DOWNLOAD_PROMPT "0")))
    (task "Fetch client version"
      (slurp 
        (src (jinja "{{ galaxy_static_dir }}") "/client_build_hash.txt"))
      (register "__galaxy_client_build_version_result"))
    (task "Set client build version fact"
      (set_fact 
        (__galaxy_client_build_version (jinja "{{ __galaxy_client_build_version_result.content | b64decode | trim }}"))))
    (task "Ensure that client update succeeded"
      (assert 
        (that (list
            "__galaxy_client_build_version == __galaxy_current_commit_id"))
        (msg "Client build version does not match repo version after building: " (jinja "{{ __galaxy_client_build_version }}") " != " (jinja "{{ __galaxy_current_commit_id }}")))
      (when "__galaxy_from_git.stat.exists"))))
