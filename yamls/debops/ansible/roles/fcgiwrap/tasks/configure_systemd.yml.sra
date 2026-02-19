(playbook "debops/ansible/roles/fcgiwrap/tasks/configure_systemd.yml"
  (tasks
    (task "Generate systemd units"
      (ansible.builtin.template 
        (src "etc/systemd/system/fcgiwrap-instance." (jinja "{{ item.1 }}") ".j2")
        (dest "/etc/systemd/system/fcgiwrap-" (jinja "{{ item.0.name }}") "." (jinja "{{ item.1 }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_nested (list
          (jinja "{{ fcgiwrap__instances }}")
          (list
            "socket"
            "service")))
      (register "fcgiwrap__register_systemd")
      (notify (list
          "Reload service manager"))
      (when "fcgiwrap__instances"))
    (task "Reload systemd units"
      (ansible.builtin.meta "flush_handlers"))
    (task "Enable and start systemd units"
      (ansible.builtin.service 
        (name "fcgiwrap-" (jinja "{{ item.0.name }}") "." (jinja "{{ item.1 }}"))
        (state "started")
        (enabled "True"))
      (with_nested (list
          (jinja "{{ fcgiwrap__instances }}")
          (list
            "socket"
            "service")))
      (when "fcgiwrap__instances and fcgiwrap__register_systemd is changed"))))
