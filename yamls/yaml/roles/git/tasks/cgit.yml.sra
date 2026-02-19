(playbook "yaml/roles/git/tasks/cgit.yml"
  (tasks
    (task "Install cgit dependencies"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "groff"
          "libssl-dev"
          "python3-pip"))
      (tags (list
          "dependencies")))
    (task "Install cgit pip dependencies python 3"
      (pip 
        (name (jinja "{{ item }}"))
        (executable "pip3"))
      (with_items (list
          "docutils"
          "pygments"
          "markdown")))
    (task "Download cgit release"
      (get_url "url=http://git.zx2c4.com/cgit/snapshot/cgit-" (jinja "{{ cgit_version }}") ".tar.xz dest=/root/cgit-" (jinja "{{ cgit_version }}") ".tar.xz"))
    (task "Decompress cgit source"
      (unarchive "src=/root/cgit-" (jinja "{{ cgit_version }}") ".tar.xz dest=/root copy=no creates=/root/cgit-" (jinja "{{ cgit_version }}") "/configure"))
    (task "Build and install cgit"
      (shell "make get-git ; make ; make install executable=/bin/bash chdir=/root/cgit-" (jinja "{{ cgit_version }}") " creates=/var/www/htdocs/cgit/cgit.cgi"))
    (task "Copy cgitrc"
      (template "src=etc_cgitrc.j2 dest=/etc/cgitrc group=www-data owner=root"))
    (task "Rename existing Apache cgit virtualhost"
      (command "mv /etc/apache2/sites-available/cgit /etc/apache2/sites-available/cgit.conf removes=/etc/apache2/sites-available/cgit"))
    (task "Remove old sites-enabled/cgit symlink (new one will be created by a2ensite)"
      (file "path=/etc/apache2/sites-enabled/cgit state=absent"))
    (task "Configure the Apache HTTP server for cgit"
      (template "src=etc_apache2_sites-available_cgit.j2 dest=/etc/apache2/sites-available/cgit.conf group=root owner=root"))
    (task "Enable Apache CGI module"
      (command "a2enmod cgi creates=/etc/apache2/mods-enabled/cgi.load")
      (notify "restart apache"))
    (task "Enable Apache rewrite module"
      (command "a2enmod rewrite creates=/etc/apache2/mods-enabled/rewrite.load")
      (notify "restart apache"))
    (task "Enable cgit site"
      (command "a2ensite cgit.conf creates=/etc/apache2/sites-enabled/cgit.conf")
      (notify "restart apache"))))
