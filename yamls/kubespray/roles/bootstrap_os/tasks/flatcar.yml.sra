(playbook "kubespray/roles/bootstrap_os/tasks/flatcar.yml"
  (tasks
    (task "Check if bootstrap is needed"
      (raw "stat /opt/bin/.bootstrapped")
      (register "need_bootstrap")
      (failed_when "false")
      (changed_when "false")
      (tags (list
          "facts")))
    (task "Run bootstrap.sh"
      (script "bootstrap.sh")
      (become "true")
      (environment (jinja "{{ proxy_env }}"))
      (when (list
          "need_bootstrap.rc != 0")))
    (task "Make interpreter discovery works on Flatcar"
      (set_fact 
        (ansible_interpreter_python_fallback (jinja "{{ (ansible_interpreter_python_fallback | default([])) + ['/opt/bin/python'] }}"))))
    (task "Disable auto-upgrade"
      (systemd_service 
        (name "locksmithd.service")
        (masked "true")
        (state "stopped"))
      (when (list
          "coreos_locksmithd_disable")))))
