(playbook "ansible-galaxy/tasks/static_subdomain_dirs.yml"
  (tasks
    (task "Create " (jinja "{{ subdomain.name }}") "'s static dirs and symlink Galaxy static files"
      (symlink_clone 
        (src (jinja "{{ galaxy_static_dir }}"))
        (path (jinja "{{ galaxy_themes_static_path }}") "/static-" (jinja "{{ subdomain.name }}") "/")
        (mode "0755")
        (owner (jinja "{{ __galaxy_privsep_user_name }}"))
        (group (jinja "{{ __galaxy_privsep_user_group }}"))))
    (task "Check if welcome.html is present in " (jinja "{{ subdomain.name }}") "'s static files"
      (ansible.builtin.stat 
        (path (jinja "{{ galaxy_themes_ansible_file_path }}") "/" (jinja "{{ subdomain.name }}") "/static/welcome.html"))
      (register "custom_welcome")
      (delegate_to "127.0.0.1")
      (become "false"))
    (task "Create welcome.html directory within " (jinja "{{ subdomain.name }}") "'s static dir"
      (ansible.builtin.file 
        (state "directory")
        (mode "0755")
        (owner (jinja "{{ __galaxy_privsep_user_name }}"))
        (group (jinja "{{ __galaxy_privsep_user_group }}"))
        (path (jinja "{{ galaxy_themes_static_path }}") "/static-" (jinja "{{ subdomain.name }}") "/welcome.html")))
    (task "Check if iframe for " (jinja "{{ subdomain.name }}") " exists"
      (ansible.builtin.uri 
        (url (jinja "{{ galaxy_themes_welcome_url_prefix }}") (jinja "{{ subdomain.name }}") ".html")
        (return_content "true"))
      (register "galaxy_themes_use_iframe")
      (failed_when "false")
      (when "not custom_welcome.stat.exists"))
    (task "Template welcome.html for " (jinja "{{ subdomain.name }}")
      (ansible.builtin.template 
        (src "welcome.html.j2")
        (dest (jinja "{{ galaxy_themes_static_path }}") "/static-" (jinja "{{ subdomain.name }}") "/welcome.html/index.html")
        (owner (jinja "{{ __galaxy_privsep_user_name }}"))
        (group (jinja "{{ __galaxy_privsep_user_group }}"))
        (mode "0644"))
      (when "not custom_welcome.stat.exists"))
    (task "Check if " (jinja "{{ subdomain.name }}") "'s static files directory exists"
      (ansible.builtin.stat 
        (path (jinja "{{ galaxy_themes_ansible_file_path }}") "/" (jinja "{{ subdomain.name }}") "/static/"))
      (register "subdomain_static_dir"))
    (task "Copy " (jinja "{{ subdomain.name }}") "'s static files"
      (ansible.builtin.copy 
        (src (jinja "{{ galaxy_themes_ansible_file_path }}") "/" (jinja "{{ subdomain.name }}") "/static/")
        (dest (jinja "{{ galaxy_themes_static_path }}") "/static-" (jinja "{{ subdomain.name }}") "/")
        (mode "0644")
        (owner (jinja "{{ __galaxy_privsep_user_name }}"))
        (group (jinja "{{ __galaxy_privsep_user_group }}")))
      (when "subdomain_static_dir.stat.exists"))
    (task "Copy custom welcome.html"
      (ansible.builtin.copy 
        (src (jinja "{{ galaxy_themes_ansible_file_path }}") "/" (jinja "{{ subdomain.name }}") "/static/welcome.html")
        (dest (jinja "{{ galaxy_themes_static_path }}") "/static-" (jinja "{{ subdomain.name }}") "/welcome.html/index.html")
        (mode "0644")
        (owner (jinja "{{ __galaxy_privsep_user_name }}"))
        (group (jinja "{{ __galaxy_privsep_user_group }}")))
      (when "custom_welcome.stat.exists"))))
