(playbook "debops/ansible/roles/gunicorn/handlers/main.yml"
  (tasks
    (task "Reload systemd daemon (gunicorn)"
      (ansible.builtin.systemd 
        (daemon_reload "True"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Restart gunicorn"
      (ansible.builtin.service 
        (name "gunicorn")
        (state "restarted")))
    (task "Start Green Unicorn instances"
      (ansible.builtin.script "script/start-gunicorn-instances"))))
