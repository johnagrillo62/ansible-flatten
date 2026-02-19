(playbook "tools/ansible/roles/dockerfile/tasks/main.yml"
  (tasks
    (task "Create _build directory"
      (file 
        (path (jinja "{{ dockerfile_dest }}") "/" (jinja "{{ template_dest }}"))
        (state "directory")))
    (task "Render supervisor configs"
      (template 
        (src (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ dockerfile_dest }}") "/" (jinja "{{ template_dest }}") "/" (jinja "{{ item }}")))
      (with_items (list
          "supervisor_web.conf"
          "supervisor_task.conf"
          "supervisor_rsyslog.conf")))
    (task "Render Dockerfile"
      (template 
        (src "Dockerfile.j2")
        (dest (jinja "{{ dockerfile_dest }}") "/" (jinja "{{ dockerfile_name }}"))))))
