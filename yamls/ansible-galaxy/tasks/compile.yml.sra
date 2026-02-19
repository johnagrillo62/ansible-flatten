(playbook "ansible-galaxy/tasks/compile.yml"
  (tasks
    (task "Remove orphaned .pyc files and compile bytecode"
      (script "makepyc.py " (jinja "{{ galaxy_server_dir }}") "/lib")
      (environment 
        (PATH (jinja "{{ galaxy_venv_dir }}") "/bin")))))
