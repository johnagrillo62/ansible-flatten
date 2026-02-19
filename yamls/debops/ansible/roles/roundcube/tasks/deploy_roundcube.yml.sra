(playbook "debops/ansible/roles/roundcube/tasks/deploy_roundcube.yml"
  (tasks
    (task "Create Roundcube group"
      (ansible.builtin.group 
        (name (jinja "{{ roundcube__group }}"))
        (system "True")
        (state "present")))
    (task "Create Roundcube user"
      (ansible.builtin.user 
        (name (jinja "{{ roundcube__user }}"))
        (group (jinja "{{ roundcube__group }}"))
        (home (jinja "{{ roundcube__home }}"))
        (shell (jinja "{{ roundcube__shell }}"))
        (comment (jinja "{{ roundcube__comment }}"))
        (system "True")
        (state "present")))
    (task "Create required Roundcube directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "directory")
        (owner (jinja "{{ roundcube__user }}"))
        (group (jinja "{{ roundcube__group }}"))
        (mode (jinja "{{ item.mode | d(\"0755\") }}")))
      (loop (list
          
          (path (jinja "{{ roundcube__src }}"))
          
          (path (jinja "{{ roundcube__git_dir | dirname }}"))
          (mode "0750")
          
          (path (jinja "{{ roundcube__git_dest | dirname }}")))))
    (task "Clone Roundcube source from upstream repository"
      (ansible.builtin.git 
        (repo (jinja "{{ roundcube__git_repo }}"))
        (dest (jinja "{{ roundcube__git_dest }}"))
        (version (jinja "{{ roundcube__git_version }}"))
        (separate_git_dir (jinja "{{ roundcube__git_dir }}"))
        (verify_commit "True"))
      (become "True")
      (become_user (jinja "{{ roundcube__user }}"))
      (register "roundcube__register_git")
      (notify (list
          "Refresh host facts")))
    (task "Read PHP composer data from upstream"
      (ansible.builtin.slurp 
        (src (jinja "{{ roundcube__git_dest + \"/composer.json-dist\" }}")))
      (register "roundcube__register_composer_dist")
      (when "roundcube__register_git is changed"))
    (task "Read currently deployed PHP composer data"
      (ansible.builtin.slurp 
        (src (jinja "{{ roundcube__git_dest + \"/composer.json\" }}")))
      (register "roundcube__register_composer_installed")
      (when "(ansible_local | d() and ansible_local.roundcube | d() and (ansible_local.roundcube.installed | d()) | bool and roundcube__register_git is changed)"))
    (task "Update PHP composer data"
      (ansible.builtin.template 
        (src "srv/www/sites/roundcube/public/composer.json.j2")
        (dest (jinja "{{ roundcube__git_dest + \"/composer.json\" }}"))
        (owner (jinja "{{ roundcube__user }}"))
        (group (jinja "{{ roundcube__group }}"))
        (mode "0644"))
      (when "roundcube__register_git is changed"))
    (task "Install or upgrade PHP packages via Composer"
      (community.general.composer 
        (command (jinja "{{ \"upgrade\"
                 if (ansible_local | d() and ansible_local.roundcube | d() and
                     (ansible_local.roundcube.installed | d()) | bool)
                 else \"install\" }}"))
        (working_dir (jinja "{{ roundcube__git_dest }}"))
        (no_dev "True"))
      (become "True")
      (become_user (jinja "{{ roundcube__user }}"))
      (register "roundcube__register_composer")
      (until "roundcube__register_composer is succeeded")
      (when "roundcube__register_git is changed"))
    (task "Install Roundcube plugins via Composer"
      (community.general.composer 
        (command "require")
        (arguments (jinja "{{ item }}"))
        (working_dir (jinja "{{ roundcube__git_dest }}"))
        (no_dev "True"))
      (loop (jinja "{{ roundcube__combined_plugins | debops.debops.parse_kv_items
            | selectattr(\"state\", \"match\", \"^(enabled|present)$\")
            | selectattr(\"package\", \"defined\")
            | map(attribute=\"package\") | list }}"))
      (become "True")
      (become_user (jinja "{{ roundcube__user }}"))
      (register "roundcube__register_composer_plugins")
      (until "roundcube__register_composer_plugins is succeeded")
      (tags (list
          "skip::roundcube:plugins")))
    (task "Install Javascript packages"
      (ansible.builtin.command "bin/install-jsdeps.sh")
      (args 
        (chdir (jinja "{{ roundcube__git_dest }}")))
      (become "True")
      (become_user (jinja "{{ roundcube__user }}"))
      (changed_when "False"))
    (task "Enable cleandb.sh Cron job"
      (ansible.builtin.cron 
        (name "Roundcube daily database housekeeping")
        (user (jinja "{{ roundcube__user }}"))
        (job (jinja "{{ roundcube__git_dest }}") "/bin/cleandb.sh > /dev/null")
        (cron_file "roundcube")
        (hour "22")
        (minute "0")))))
