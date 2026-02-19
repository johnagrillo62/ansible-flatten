(playbook "ansible-galaxy/tasks/static_dirs.yml"
  (tasks
    (task "Create welcome.html directory for basedomain"
      (ansible.builtin.file 
        (state "directory")
        (mode "0755")
        (owner (jinja "{{ __galaxy_privsep_user_name }}"))
        (group (jinja "{{ __galaxy_privsep_user_group }}"))
        (path (jinja "{{ galaxy_themes_static_path }}") "/static/welcome.html")))
    (task "Template welcome.html for basedomain"
      (ansible.builtin.template 
        (src "welcome.html.j2")
        (dest (jinja "{{ galaxy_themes_static_path }}") "/static/welcome.html/index.html")
        (owner (jinja "{{ __galaxy_privsep_user_name }}"))
        (group (jinja "{{ __galaxy_privsep_user_group }}"))
        (mode "0644")))
    (task "Include create subdomain static dirs and link/copy static files"
      (ansible.builtin.include_tasks "static_subdomain_dirs.yml")
      (loop (jinja "{{ galaxy_themes_subdomains if galaxy_themes_subdomains | length or \\
    galaxy_manage_subdomain_static else [] }}"))
      (loop_control 
        (loop_var "subdomain")))))
