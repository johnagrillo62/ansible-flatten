(playbook "debops/ansible/roles/dokuwiki/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"dokuwiki/pre_main.yml\") }}")))
    (task "Install requested packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (dokuwiki__base_packages
                              + dokuwiki__packages)) }}"))
        (state "present"))
      (register "dokuwiki__register_packages")
      (until "dokuwiki__register_packages is succeeded"))
    (task "Create DokuWiki group"
      (ansible.builtin.group 
        (name (jinja "{{ dokuwiki__group }}"))
        (system "True")
        (state "present")))
    (task "Create DokuWiki user"
      (ansible.builtin.user 
        (name (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__group }}"))
        (home (jinja "{{ dokuwiki__home }}"))
        (shell (jinja "{{ dokuwiki__shell }}"))
        (comment "DokuWiki")
        (createhome "False")
        (system "True")
        (state "present")))
    (task "Create DokuWiki source directory"
      (ansible.builtin.file 
        (path (jinja "{{ dokuwiki__src }}"))
        (state "directory")
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__group }}"))
        (mode "0750")))
    (task "Clone DokuWiki source from deploy server"
      (ansible.builtin.git 
        (repo (jinja "{{ dokuwiki__git_repo }}"))
        (dest (jinja "{{ dokuwiki__git_dest }}"))
        (version "master")
        (bare "True")
        (update "True"))
      (become "True")
      (become_user (jinja "{{ dokuwiki__user }}"))
      (register "dokuwiki__register_source")
      (until "dokuwiki__register_source is succeeded"))
    (task "Create DokuWiki checkout directory"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__webserver_user }}"))
        (mode "0750"))
      (with_items (list
          (jinja "{{ dokuwiki__www }}")
          (jinja "{{ dokuwiki__git_checkout }}"))))
    (task "Prepare DokuWiki worktree"
      (ansible.builtin.copy 
        (content "gitdir: " (jinja "{{ dokuwiki__git_dest }}"))
        (dest (jinja "{{ dokuwiki__git_checkout + \"/.git\" }}"))
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__group }}"))
        (mode "0644")))
    (task "Get commit hash of target checkout"
      (ansible.builtin.command "git rev-parse " (jinja "{{ dokuwiki__git_version }}"))
      (environment 
        (GIT_WORK_TREE (jinja "{{ dokuwiki__git_checkout }}")))
      (args 
        (chdir (jinja "{{ dokuwiki__git_dest }}")))
      (become "True")
      (become_user (jinja "{{ dokuwiki__user }}"))
      (register "dokuwiki__register_target_branch")
      (changed_when "dokuwiki__register_target_branch.stdout != dokuwiki__register_source.before"))
    (task "Checkout DokuWiki"
      (ansible.builtin.command "git checkout -f " (jinja "{{ dokuwiki__git_version }}"))
      (environment 
        (GIT_WORK_TREE (jinja "{{ dokuwiki__git_checkout }}")))
      (args 
        (chdir (jinja "{{ dokuwiki__git_dest }}")))
      (become "True")
      (become_user (jinja "{{ dokuwiki__user }}"))
      (register "dokuwiki__register_checkout")
      (changed_when "dokuwiki__register_checkout.changed | bool")
      (when "(dokuwiki__register_source.before is undefined or (dokuwiki__register_source.before is defined and dokuwiki__register_target_branch.stdout is defined and dokuwiki__register_source.before != dokuwiki__register_target_branch.stdout))"))
    (task "Remove specified plugins if requested"
      (ansible.builtin.file 
        (path (jinja "{{ dokuwiki__git_checkout + \"/lib/plugins/\" + item.dest }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", dokuwiki__default_plugins
                           + dokuwiki__plugins) }}"))
      (when "(dokuwiki__plugins_enabled | bool and (item.dest | d() and item.dest) and (item.state | d() and item.state == 'absent'))"))
    (task "Install specified plugins from git repositories"
      (ansible.builtin.git 
        (repo (jinja "{{ item.repo }}"))
        (dest (jinja "{{ dokuwiki__git_checkout + \"/lib/plugins/\" + item.dest }}"))
        (version (jinja "{{ item.version | d(omit) }}"))
        (update "True"))
      (become "True")
      (become_user (jinja "{{ dokuwiki__user }}"))
      (loop (jinja "{{ q(\"flattened\", dokuwiki__default_plugins
                           + dokuwiki__plugins) }}"))
      (register "dokuwiki__register_git_plugins")
      (until "dokuwiki__register_git_plugins is succeeded")
      (when "(dokuwiki__plugins_enabled | bool and (item.repo | d() and item.repo) and (item.dest | d() and item.dest) and (item.state is undefined or (item.state | d() and item.state != 'absent')))"))
    (task "Remove specified templates if requested"
      (ansible.builtin.file 
        (path (jinja "{{ dokuwiki__git_checkout + \"/lib/tpl/\" + item.dest }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", dokuwiki__default_templates
                           + dokuwiki__templates) }}"))
      (when "(dokuwiki__plugins_enabled | bool and (item.dest | d() and item.dest) and (item.state | d() and item.state == 'absent'))"))
    (task "Install specified templates from git repositories"
      (ansible.builtin.git 
        (repo (jinja "{{ item.repo }}"))
        (dest (jinja "{{ dokuwiki__git_checkout + \"/lib/tpl/\" + item.dest }}"))
        (version (jinja "{{ item.version | d(omit) }}"))
        (update "True"))
      (become "True")
      (become_user (jinja "{{ dokuwiki__user }}"))
      (loop (jinja "{{ q(\"flattened\", dokuwiki__default_templates
                           + dokuwiki__templates) }}"))
      (register "dokuwiki__register_git_templates")
      (until "dokuwiki__register_git_templates is succeeded")
      (when "(dokuwiki__plugins_enabled | bool and (item.repo | d() and item.repo) and (item.dest | d() and item.dest) and (item.state is undefined or (item.state | d() and item.state != 'absent')))"))
    (task "Generate protected local configuration file"
      (ansible.builtin.template 
        (src "srv/www/dokuwiki/sites/public/conf/local.protected.php.j2")
        (dest (jinja "{{ dokuwiki__git_checkout + \"/conf/local.protected.php\" }}"))
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__group }}"))
        (mode "0600"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (tags (list
          "role::dokuwiki:conf")))
    (task "Generate protected plugin configuration file"
      (ansible.builtin.template 
        (src "srv/www/dokuwiki/sites/public/conf/plugins.protected.php.j2")
        (dest (jinja "{{ dokuwiki__git_checkout + \"/conf/plugins.protected.php\" }}"))
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__group }}"))
        (mode "0600"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (tags (list
          "role::dokuwiki:conf")))
    (task "Generate local MIME configuration file"
      (ansible.builtin.template 
        (src "srv/www/dokuwiki/sites/public/conf/mime.local.conf.j2")
        (dest (jinja "{{ dokuwiki__git_checkout + \"/conf/mime.local.conf\" }}"))
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__group }}"))
        (mode "0600"))
      (tags (list
          "role::dokuwiki:conf"
          "role::dokuwiki:mime")))
    (task "Install maintenance scripts"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0755"))
      (with_items (list
          "etc/cron.daily/dokuwiki-cleanup"
          "etc/cron.weekly/dokuwiki-wikipedia-blacklist")))
    (task "Create farm base directory"
      (ansible.builtin.file 
        (path (jinja "{{ dokuwiki__farm_path }}"))
        (state "directory")
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__webserver_user }}"))
        (mode "0750"))
      (when "dokuwiki__farm | bool"))
    (task "Create farm animal directories"
      (ansible.builtin.copy 
        (src "srv/www/dokuwiki/farm/animal/")
        (dest (jinja "{{ dokuwiki__farm_path + \"/\" + item + \"/\" }}"))
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__webserver_user }}"))
        (mode "0750")
        (force "False"))
      (with_items (jinja "{{ dokuwiki__farm_animals }}"))
      (when "(dokuwiki__farm | bool and dokuwiki__farm_animals)"))
    (task "Disable DokuWiki farm if not enabled"
      (ansible.builtin.file 
        (path (jinja "{{ dokuwiki__git_checkout + \"/inc/preload.php\" }}"))
        (state "absent"))
      (when "(not dokuwiki__farm | bool or not dokuwiki__farm_animals)"))
    (task "Configure DokuWiki farm preload script"
      (ansible.builtin.template 
        (src "srv/www/dokuwiki/sites/public/inc/preload.php.j2")
        (dest (jinja "{{ dokuwiki__git_checkout + \"/inc/preload.php\" }}"))
        (owner (jinja "{{ dokuwiki__user }}"))
        (group (jinja "{{ dokuwiki__group }}"))
        (mode "0644"))
      (when "(dokuwiki__farm | bool and dokuwiki__farm_animals)"))
    (task "Download initial anti-spam blacklist"
      (ansible.builtin.command "/etc/cron.weekly/dokuwiki-wikipedia-blacklist")
      (args 
        (creates (jinja "{{ dokuwiki__git_checkout + \"/conf/wordblock.local.conf\" }}"))))
    (task "Delete extra files on remote host"
      (ansible.builtin.file 
        (path (jinja "{{ item.dest | d(item.path | d(item.name)) }}"))
        (state "absent"))
      (loop (jinja "{{ q(\"flattened\", dokuwiki__extra_files
                           + dokuwiki__group_extra_files
                           + dokuwiki__host_extra_files) }}"))
      (when "(item.dest | d() or item.path | d() or item.name | d()) and (item.state | d('present') == 'absent')")
      (tags (list
          "role::dokuwiki")))
    (task "Copy extra files to remote host"
      (ansible.builtin.copy 
        (dest (jinja "{{ item.dest | d(item.path | d(item.name)) }}"))
        (src (jinja "{{ item.src | d(omit) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (owner (jinja "{{ item.owner | d(omit) }}"))
        (group (jinja "{{ item.group | d(omit) }}"))
        (mode (jinja "{{ item.mode | d(omit) }}"))
        (selevel (jinja "{{ item.selevel | d(omit) }}"))
        (serole (jinja "{{ item.serole | d(omit) }}"))
        (setype (jinja "{{ item.setype | d(omit) }}"))
        (seuser (jinja "{{ item.seuser | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (backup (jinja "{{ item.backup | d(omit) }}"))
        (validate (jinja "{{ item.validate | d(omit) }}"))
        (remote_src (jinja "{{ item.remote_src | d(omit) }}"))
        (directory_mode (jinja "{{ item.directory_mode | d(omit) }}")))
      (loop (jinja "{{ q(\"flattened\", dokuwiki__extra_files
                           + dokuwiki__group_extra_files
                           + dokuwiki__host_extra_files) }}"))
      (when "(item.src | d() or item.content is defined) and (item.dest | d() or item.path | d() or item.name | d()) and (item.state | d('present') != 'absent')")
      (tags (list
          "role::dokuwiki")))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"dokuwiki/post_main.yml\") }}")))))
