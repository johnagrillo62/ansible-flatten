(playbook "debops/ansible/roles/netbox/handlers/main.yml"
  (tasks
    (task "Reload systemd daemon (netbox)"
      (ansible.builtin.systemd 
        (daemon_reload "True"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Restart gunicorn for netbox"
      (ansible.builtin.service 
        (name "gunicorn@netbox")
        (state "restarted"))
      (when "(not netbox__app_internal_appserver | bool and ansible_local.gunicorn.installed | d() | bool)"))
    (task "Restart netbox internal appserver"
      (ansible.builtin.service 
        (name "netbox")
        (state "restarted")
        (enabled "True"))
      (when "netbox__app_internal_appserver | bool"))
    (task "Restart netbox Request Queue Worker"
      (ansible.builtin.service 
        (name "netbox-rq")
        (state "restarted")
        (enabled "True"))
      (when "netbox__app_internal_appserver | bool"))))
