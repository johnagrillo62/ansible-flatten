(playbook "yaml/roles/blog/tasks/blog.yml"
  (tasks
    (task "Create directory for blog HTML"
      (file "state=directory path=/var/www/" (jinja "{{ domain }}") " group=www-data owner=" (jinja "{{ main_user_name }}")))
    (task "Rename existing Apache blog virtualhost"
      (command "mv /etc/apache2/sites-available/" (jinja "{{ domain }}") " /etc/apache2/sites-available/" (jinja "{{ domain }}") ".conf removes=/etc/apache2/sites-available/" (jinja "{{ domain }}")))
    (task "Remove old sites-enabled/" (jinja "{{ domain }}") " symlink (new one will be created by a2ensite)"
      (file "path=/etc/apache2/sites-enabled/" (jinja "{{ domain }}") " state=absent"))
    (task "Configure the Apache HTTP server for the blog"
      (template "src=etc_apache2_sites-available_blog.j2 dest=/etc/apache2/sites-available/" (jinja "{{ domain }}") ".conf group=root owner=root"))
    (task "Enable blog site"
      (command "a2ensite " (jinja "{{ domain }}") ".conf creates=/etc/apache2/sites-enabled/" (jinja "{{ domain }}") ".conf")
      (notify "restart apache"))))
