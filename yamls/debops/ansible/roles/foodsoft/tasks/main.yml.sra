(playbook "debops/ansible/roles/foodsoft/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Ensure specified packages are in there desired state"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", foodsoft__base_packages) }}"))
        (state (jinja "{{ \"present\" if (foodsoft__deploy_state == \"present\") else \"absent\" }}")))
      (register "foodsoft__register_packages")
      (until "foodsoft__register_packages is succeeded")
      (tags (list
          "role::foodsoft:pkgs")))
    (task "Create Foodsoft system group"
      (ansible.builtin.group 
        (name (jinja "{{ foodsoft__group }}"))
        (state (jinja "{{ \"present\" if (foodsoft__deploy_state == \"present\") else \"absent\" }}"))
        (system "True")))
    (task "Create Foodsoft system user"
      (ansible.builtin.user 
        (name (jinja "{{ foodsoft__user }}"))
        (group (jinja "{{ foodsoft__group }}"))
        (home (jinja "{{ foodsoft__home_path }}"))
        (comment (jinja "{{ foodsoft__gecos }}"))
        (shell (jinja "{{ foodsoft__shell }}"))
        (state (jinja "{{ \"present\" if (foodsoft__deploy_state == \"present\") else \"absent\" }}"))
        (system "True")))
    (task "Clone Foodsoft git repository"
      (ansible.builtin.git 
        (repo (jinja "{{ foodsoft__git_repo }}"))
        (dest (jinja "{{ foodsoft__git_dest }}"))
        (version (jinja "{{ foodsoft__git_version }}"))
        (update (jinja "{{ foodsoft__git_update | bool }}")))
      (become "True")
      (become_user (jinja "{{ foodsoft__user }}"))
      (register "foodsoft__register_git")
      (when "(foodsoft__deploy_state == \"present\")"))
    (task "Update Foodsoft directory permissions"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ foodsoft__user }}"))
        (group (jinja "{{ foodsoft__webserver_user }}"))
        (mode "0750"))
      (with_items (list
          (jinja "{{ foodsoft__home_path }}")
          (jinja "{{ foodsoft__git_dest }}"))))
    (task "Install Foodsoft dependencies via bundler"
      (community.general.bundler 
        (chdir (jinja "{{ foodsoft__git_dest }}"))
        (exclude_groups (jinja "{{ foodsoft__bundler_exclude_groups }}"))
        (extra_args "--without development --deployment"))
      (register "foodsoft__register_bundler")
      (until "foodsoft__register_bundler is succeeded")
      (tags (list
          "role::foodsoft:gems"))
      (when "foodsoft__bundler_exclude_groups | d()"))
    (task "Configure Foodsoft"
      (ansible.builtin.template 
        (src "srv/www/foodsoft/app/config/" (jinja "{{ item }}") ".j2")
        (dest (jinja "{{ foodsoft__git_dest }}") "/config/" (jinja "{{ item }}"))
        (owner (jinja "{{ foodsoft__user }}"))
        (group (jinja "{{ foodsoft__group }}"))
        (mode "0640"))
      (tags (list
          "role::foodsoft:config"))
      (with_items (list
          "database.yml"
          "app_config.yml")))
    (task "Generate secret token"
      (ansible.builtin.command "bundle exec rake secret")
      (args 
        (chdir (jinja "{{ foodsoft__git_dest }}"))
        (creates (jinja "{{ foodsoft__git_dest }}") "/config/initializers/secret_token.rb"))
      (register "foodsoft__register_secret_token")
      (tags (list
          "role::foodsoft:gen_token")))
    (task "Check secret token"
      (ansible.builtin.assert 
        (that (list
            "foodsoft__register_secret_token.stdout | length > 120"
            "foodsoft__register_secret_token.stdout | length < 500")))
      (when "foodsoft__register_secret_token is changed")
      (tags (list
          "role::foodsoft:gen_token")))
    (task "Configure secret token for Foodsoft"
      (ansible.builtin.template 
        (src "srv/www/foodsoft/app/config/initializers/secret_token.rb.j2")
        (dest (jinja "{{ foodsoft__git_dest }}") "/config/initializers/secret_token.rb")
        (owner (jinja "{{ foodsoft__user }}"))
        (group (jinja "{{ foodsoft__group }}"))
        (mode "0640"))
      (tags (list
          "role::foodsoft:gen_token"))
      (when "foodsoft__register_secret_token is changed"))
    (task "Create database schema and load defaults"
      (ansible.builtin.command "bundle exec rake db:setup")
      (args 
        (chdir (jinja "{{ foodsoft__git_dest }}")))
      (register "foodsoft__register_db_setup")
      (changed_when "foodsoft__register_db_setup.changed | bool")
      (when "(not (ansible_local.foodsoft[foodsoft__database + \"_initialized\"] | bool if (ansible_local | d() and ansible_local.foodsoft | d() and ansible_local.foodsoft[foodsoft__database + \"_initialized\"] | d()) else False))"))
    (task "Make sure that Ansible local facts directory is present"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "(foodsoft__deploy_state == \"present\")"))
    (task "Save Foodsoft local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/foodsoft.fact.j2")
        (dest "/etc/ansible/facts.d/foodsoft.fact")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Refresh host facts"))
      (when "(foodsoft__deploy_state == \"present\")")
      (tags (list
          "meta::facts")))
    (task "Gather facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
