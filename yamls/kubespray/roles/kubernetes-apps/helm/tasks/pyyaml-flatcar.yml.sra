(playbook "kubespray/roles/kubernetes-apps/helm/tasks/pyyaml-flatcar.yml"
  (tasks
    (task "Get installed pip version"
      (command (jinja "{{ ansible_python_interpreter if ansible_python_interpreter is defined else 'python' }}") " -m pip --version")
      (register "pip_version_output")
      (ignore_errors "true")
      (changed_when "false"))
    (task "Get installed PyYAML version"
      (command (jinja "{{ ansible_python_interpreter if ansible_python_interpreter is defined else 'python' }}") " -m pip show PyYAML")
      (register "pyyaml_version_output")
      (ignore_errors "true")
      (changed_when "false"))
    (task "Install pip"
      (command (jinja "{{ ansible_python_interpreter if ansible_python_interpreter is defined else 'python' }}") " -m ensurepip --upgrade")
      (when "(pyyaml_version_output is failed) and (pip_version_output is failed)"))
    (task "Install PyYAML"
      (ansible.builtin.pip 
        (name (list
            "PyYAML")))
      (when "(pyyaml_version_output is failed)"))))
