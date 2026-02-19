(playbook "debops/ansible/roles/gunicorn/tasks/older_releases.yml"
  (tasks
    (task "Make sure /etc/gunicorn.d/ directory exists"
      (ansible.builtin.file 
        (path "/etc/gunicorn.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Remove gunicorn configuration"
      (ansible.builtin.file 
        (path "/etc/gunicorn.d/" (jinja "{{ item.name }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (notify (list
          "Restart gunicorn"))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate gunicorn configuration"
      (ansible.builtin.template 
        (src "etc/gunicorn.d/application.j2")
        (dest "/etc/gunicorn.d/" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", gunicorn__applications
                           + gunicorn__dependent_applications) }}"))
      (notify (list
          "Restart gunicorn"))
      (when "item.name | d() and item.state | d('present') != 'absent'"))))
