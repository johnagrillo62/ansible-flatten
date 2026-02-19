(playbook "debops/ansible/roles/phpipam/tasks/phpipam.yml"
  (tasks
    (task "Create phpIPAM group"
      (ansible.builtin.group 
        (name (jinja "{{ phpipam__group }}"))
        (system "True")
        (state "present")))
    (task "Create phpIPAM user"
      (ansible.builtin.user 
        (name (jinja "{{ phpipam__user }}"))
        (group (jinja "{{ phpipam__group }}"))
        (home (jinja "{{ phpipam__home }}"))
        (shell "/usr/sbin/nologin")
        (comment "phpIPAM")
        (system "True")
        (state "present")
        (createhome "False")))
    (task "Create phpIPAM source directory"
      (ansible.builtin.file 
        (path (jinja "{{ phpipam__src }}"))
        (state "directory")
        (owner (jinja "{{ phpipam__user }}"))
        (group (jinja "{{ phpipam__group }}"))
        (mode "0750")))
    (task "Clone phpIPAM source from deploy server"
      (ansible.builtin.git 
        (repo (jinja "{{ phpipam__git_repo }}"))
        (dest (jinja "{{ phpipam__git_dest }}"))
        (version "master")
        (bare "True")
        (update "True"))
      (become "True")
      (become_user (jinja "{{ phpipam__user }}"))
      (register "phpipam__register_source")
      (no_log (jinja "{{ debops__no_log | d(True) }}")))
    (task "Create phpIPAM checkout directory"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ phpipam__user }}"))
        (group (jinja "{{ phpipam__webserver_user }}"))
        (mode "0750"))
      (with_items (list
          (jinja "{{ phpipam__www }}")
          (jinja "{{ phpipam__git_checkout }}"))))
    (task "Prepare phpIPAM worktree"
      (ansible.builtin.copy 
        (content "gitdir: " (jinja "{{ phpipam__git_dest }}"))
        (dest (jinja "{{ phpipam__git_checkout + \"/.git\" }}"))
        (owner (jinja "{{ phpipam__user }}"))
        (group (jinja "{{ phpipam__group }}"))
        (mode "0644")))
    (task "Get commit hash of target checkout"
      (ansible.builtin.command "git rev-parse " (jinja "{{ phpipam__git_version }}"))
      (environment 
        (GIT_WORK_TREE (jinja "{{ phpipam__git_checkout }}")))
      (args 
        (chdir (jinja "{{ phpipam__git_dest }}")))
      (become "True")
      (become_user (jinja "{{ phpipam__user }}"))
      (register "phpipam__register_target_branch")
      (changed_when "phpipam__register_target_branch.stdout != phpipam__register_source.before"))
    (task "Checkout phpIPAM"
      (ansible.builtin.command "git checkout -f " (jinja "{{ phpipam__git_version }}"))
      (environment 
        (GIT_WORK_TREE (jinja "{{ phpipam__git_checkout }}")))
      (args 
        (chdir (jinja "{{ phpipam__git_dest }}")))
      (become "True")
      (become_user (jinja "{{ phpipam__user }}"))
      (register "phpipam__register_checkout")
      (changed_when "phpipam__register_checkout.changed | bool")
      (when "(phpipam__register_source.before is undefined or (phpipam__register_source.before is defined and phpipam__register_target_branch.stdout is defined and phpipam__register_source.before != phpipam__register_target_branch.stdout))"))
    (task "Check if phpIPAM configuration exists"
      (ansible.builtin.stat 
        (path (jinja "{{ phpipam__git_checkout + \"/config.php\" }}")))
      (register "phpipam__register_configuration"))
    (task "Check if MySQL server is installed"
      (ansible.builtin.stat 
        (path "/var/lib/mysql"))
      (register "phpipam__register_mysql"))
    (task "Create phpIPAM database in local MySQL instance"
      (community.mysql.mysql_db 
        (name (jinja "{{ phpipam__database_name }}"))
        (state "present")
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (when "phpipam__database_host == 'localhost' and phpipam__register_mysql.stat.exists")
      (register "phpipam__register_database_status"))
    (task "Import initial database schema"
      (community.mysql.mysql_db 
        (name (jinja "{{ phpipam__database_name }}"))
        (state "import")
        (target (jinja "{{ phpipam__database_schema }}"))
        (login_unix_socket "/run/mysqld/mysqld.sock"))
      (when "(phpipam__database_host == 'localhost' and (phpipam__register_database_status is defined and phpipam__register_database_status is changed) and (phpipam__register_configuration is defined and not phpipam__register_configuration.stat.exists))"))
    (task "Configure phpIPAM"
      (ansible.builtin.template 
        (src "srv/www/sites/config.php.j2")
        (dest (jinja "{{ phpipam__git_checkout + \"/config.php\" }}"))
        (owner "root")
        (group "root")
        (mode "0644")))
    (task "Create import directory"
      (ansible.builtin.file 
        (path (jinja "{{ phpipam__git_checkout + \"/site/admin/csvupload\" }}"))
        (state "directory")
        (owner (jinja "{{ phpipam__user }}"))
        (group (jinja "{{ phpipam__group }}"))
        (mode "0755")))))
