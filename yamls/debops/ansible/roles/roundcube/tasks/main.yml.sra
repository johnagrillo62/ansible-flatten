(playbook "debops/ansible/roles/roundcube/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Pre hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"roundcube/pre_main.yml\") }}")))
    (task "Get version of current Roundcube installation"
      (ansible.builtin.command "sed -n \"s/^define('RCMAIL_VERSION', '\\(.*\\)');/\\1/p\" \\ " (jinja "{{ roundcube__git_dest }}") "/program/include/iniset.php")
      (changed_when "False")
      (failed_when "False")
      (register "roundcube__register_version")
      (tags (list
          "role::roundcube:database")))
    (task "Install pre-requisite packages for Roundcube"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (roundcube__base_packages
                              + roundcube__packages)) }}"))
        (state "present"))
      (register "roundcube__register_packages")
      (until "roundcube__register_packages is succeeded")
      (tags (list
          "role::roundcube:pkg")))
    (task "Deploy Roundcube"
      (ansible.builtin.include_tasks "deploy_roundcube.yml")
      (tags (list
          "role::roundcube:deployment")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save RoundCube local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/roundcube.fact.j2")
        (dest "/etc/ansible/facts.d/roundcube.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Configure skins"
      (ansible.builtin.include_tasks "configure_skins.yml")
      (tags (list
          "role::roundcube:skins"
          "role::roundcube:themes")))
    (task "Make sure database directory exists"
      (ansible.builtin.file 
        (path (jinja "{{ roundcube__git_dest }}") "/" (jinja "{{ roundcube__database_map[roundcube__database].dbname | dirname }}"))
        (state "directory")
        (owner (jinja "{{ roundcube__user }}"))
        (group (jinja "{{ roundcube__group }}"))
        (mode "0750"))
      (when "roundcube__database_map[roundcube__database].dbtype == 'sqlite'")
      (tags (list
          "role::roundcube:database")))
    (task "Configure MySQL/MariaDB support"
      (ansible.builtin.include_tasks "configure_mysql.yml")
      (when "roundcube__database_map[roundcube__database].dbtype == 'mysql'")
      (tags (list
          "role::roundcube:database")))
    (task "Configure PostgreSQL support"
      (ansible.builtin.include_tasks "configure_postgresql.yml")
      (when "roundcube__database_map[roundcube__database].dbtype == 'postgresql'")
      (tags (list
          "role::roundcube:database")))
    (task "Generate Roundcube configuration"
      (ansible.builtin.template 
        (src "srv/www/sites/roundcube/public/config/config.inc.php.j2")
        (dest (jinja "{{ roundcube__git_dest + \"/config/config.inc.php\" }}"))
        (owner "root")
        (group (jinja "{{ roundcube__group }}"))
        (mode "0640"))
      (tags (list
          "role::roundcube:config")))
    (task "Generate Roundcube plugin configuration"
      (ansible.builtin.template 
        (src "srv/www/sites/roundcube/public/plugins/config.inc.php.j2")
        (dest (jinja "{{ roundcube__git_dest + \"/plugins/\" + item.name + \"/config.inc.php\" }}"))
        (owner "root")
        (group (jinja "{{ roundcube__group }}"))
        (mode "0640"))
      (loop (jinja "{{ roundcube__combined_plugins | debops.debops.parse_kv_items
            | selectattr(\"state\", \"match\", \"^(enabled|present)$\")
            | selectattr(\"options\", \"defined\") | list }}"))
      (loop_control 
        (label (jinja "{{ item.name }}")))
      (tags (list
          "role::roundcube:config")))
    (task "Update database schema"
      (ansible.builtin.command "php bin/updatedb.sh --package=roundcube --dir=" (jinja "{{ roundcube__git_dest }}") "/SQL")
      (args 
        (chdir (jinja "{{ roundcube__git_dest }}")))
      (become "True")
      (become_user (jinja "{{ roundcube__user }}"))
      (register "roundcube__register_updatedb")
      (changed_when "roundcube__register_updatedb.stdout | d()")
      (when "(roundcube__register_version.stdout | d() and (ansible_local.roundcube.version | d(\"0.0.0\")) is version_compare(roundcube__register_version.stdout, '>'))")
      (tags (list
          "role::roundcube:database")))
    (task "Post hooks"
      (ansible.builtin.include_tasks (jinja "{{ lookup(\"debops.debops.task_src\", \"roundcube/post_main.yml\") }}")))))
