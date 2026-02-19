(playbook "debops/ansible/roles/gunicorn/tasks/newer_releases.yml"
  (tasks
    (task "Ensure that configuration directory exists"
      (ansible.builtin.file 
        (path "/etc/gunicorn")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Ensure that required groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group }}"))
        (system (jinja "{{ (item.system | d(True)) | bool }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (when "item.name | d() and item.state | d('present') != 'absent' and item.group | d()"))
    (task "Ensure that required users exist"
      (ansible.builtin.user 
        (name (jinja "{{ item.user }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (home (jinja "{{ item.home }}"))
        (system (jinja "{{ (item.system | d(True)) | bool }}"))
        (state "present"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (when "item.name | d() and item.state | d('present') != 'absent' and item.user | d() and item.home | d()"))
    (task "Create log directories"
      (ansible.builtin.file 
        (path "/var/log/gunicorn/" (jinja "{{ item.name }}"))
        (state "directory")
        (owner (jinja "{{ item.user | d(gunicorn__user) }}"))
        (group (jinja "{{ item.group | d(gunicorn__group) }}"))
        (mode "0775"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (when "item.name | d() and item.state | d('present') != 'absent'"))
    (task "Create logrotate configs"
      (ansible.builtin.template 
        (src "etc/logrotate.d/gunicorn.j2")
        (dest "/etc/logrotate.d/gunicorn-" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (when "item.name | d() and item.state | d('present') != 'absent'"))
    (task "Check if systemd instances for Green Unicorn are configured"
      (ansible.builtin.stat 
        (path "/etc/systemd/system/gunicorn@.service"))
      (register "gunicorn__register_systemd_templated"))
    (task "Stop and disable Green Unicorn instances if requested"
      (ansible.builtin.systemd 
        (name "gunicorn@" (jinja "{{ item.name }}") ".service")
        (state "stopped")
        (enabled "False"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (notify (list
          "Reload systemd daemon (gunicorn)"))
      (when "ansible_service_mgr == 'systemd' and gunicorn__register_systemd_templated.stat | d() and gunicorn__register_systemd_templated.stat.exists | bool and item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate systemd configuration files"
      (ansible.builtin.template 
        (src "etc/systemd/system/" (jinja "{{ item }}") ".j2")
        (dest "/etc/systemd/system/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "gunicorn.service"
          "gunicorn@.service"))
      (notify (list
          "Reload systemd daemon (gunicorn)"))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Remove per-instance systemd configuration"
      (ansible.builtin.file 
        (path "/etc/systemd/system/gunicorn@" (jinja "{{ item.name }}") ".service.d")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (notify (list
          "Reload systemd daemon (gunicorn)"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') == 'absent'"))
    (task "Create per-instance systemd directory"
      (ansible.builtin.file 
        (path "/etc/systemd/system/gunicorn@" (jinja "{{ item.name }}") ".service.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') != 'absent'"))
    (task "Generate per-instance systemd configuration"
      (ansible.builtin.template 
        (src "etc/systemd/system/gunicorn@application.service.d/instance.conf.j2")
        (dest "/etc/systemd/system/gunicorn@" (jinja "{{ item.name }}") ".service.d/instance.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (notify (list
          "Reload systemd daemon (gunicorn)"
          "Start Green Unicorn instances"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') != 'absent'"))
    (task "Remove Unicorn instance configuration"
      (ansible.builtin.file 
        (path "/etc/gunicorn/" (jinja "{{ item.name }}") ".conf.py")
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate Unicorn instance configuration"
      (ansible.builtin.template 
        (src "etc/gunicorn/application.conf.py.j2")
        (dest "/etc/gunicorn/" (jinja "{{ item.name }}") ".conf.py")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Start Green Unicorn instances"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (when "item.name | d() and item.state | d('present') != 'absent'"))
    (task "Reload systemd configuration"
      (ansible.builtin.meta "flush_handlers"))
    (task "Enable Unicorn instances in systemd"
      (ansible.builtin.systemd 
        (name "gunicorn@" (jinja "{{ item.name }}") ".service")
        (enabled "True"))
      (notify (list
          "Start Green Unicorn instances"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (when "ansible_service_mgr == 'systemd' and item.name | d() and item.state | d('present') != 'absent'"))))
