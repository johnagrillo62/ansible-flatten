(playbook "debops/ansible/roles/rails_deploy/tasks/deploy.yml"
  (tasks
    (task "Clone the app's source code"
      (ansible.builtin.git 
        (repo (jinja "{{ rails_deploy_git_location }}"))
        (dest (jinja "{{ rails_deploy_src }}"))
        (version (jinja "{{ rails_deploy_git_version }}"))
        (remote (jinja "{{ rails_deploy_git_remote }}"))
        (accept_hostkey "True"))
      (register "rails_deploy_register_repo_status")
      (when "rails_deploy_git_location is defined and rails_deploy_git_location")
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}")))
    (task "Detect a temporary public deploy page"
      (ansible.builtin.stat 
        (path (jinja "{{ rails_deploy_src }}") "/public/deploy.html"))
      (register "rails_deploy_register_public_deploy_page"))
    (task "Enable the temporary deploy page"
      (ansible.builtin.copy 
        (src (jinja "{{ rails_deploy_src }}") "/public/deploy.html")
        (dest (jinja "{{ rails_deploy_src }}") "/public/index.html")
        (mode "0644")
        (remote_src "True"))
      (when "rails_deploy_register_public_deploy_page.stat.exists and rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed")
      (changed_when "False")
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}")))
    (task "Update gems"
      (ansible.builtin.command "bundle install --deployment --without=" (jinja "{{ rails_deploy_bundle_without | difference([rails_deploy_system_env]) | join(',') }}"))
      (args 
        (chdir (jinja "{{ rails_deploy_src }}")))
      (changed_when "False")
      (when "rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed")
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}")))
    (task "Restart the background worker asynchronously"
      (ansible.builtin.service 
        (name (jinja "{{ rails_deploy_worker }}"))
        (state "restarted"))
      (async "90")
      (when "rails_deploy_worker_enabled and rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed"))
    (task "Prepare the database"
      (ansible.builtin.shell (jinja "{{ rails_deploy_env_source }}") " && bundle exec rake db:schema:load db:seed")
      (args 
        (chdir (jinja "{{ rails_deploy_src }}")))
      (when "(rails_deploy_database_create and rails_deploy_register_database_created is defined and rails_deploy_register_database_created is changed and rails_app_database_prepare) and inventory_hostname == rails_deploy_hosts_master and rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed")
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}"))
      (register "rails_deploy__register_db_schema_load")
      (changed_when "rails_deploy__register_db_schema_load.changed | bool"))
    (task "Store mtime of the config folder"
      (ansible.builtin.stat 
        (path (jinja "{{ rails_deploy_src }}") "/config"))
      (register "rails_deploy_register_mtime_config")
      (when "inventory_hostname == rails_deploy_hosts_master and rails_deploy_git_location is defined and rails_deploy_git_location"))
    (task "Store mtime of the db/schema.rb file"
      (ansible.builtin.stat 
        (path (jinja "{{ rails_deploy_src }}") "/db/schema.rb"))
      (register "rails_deploy_register_mtime_schema")
      (when "inventory_hostname == rails_deploy_hosts_master and rails_deploy_git_location is defined and rails_deploy_git_location"))
    (task "Execute shell commands before migration"
      (ansible.builtin.shell (jinja "{{ rails_deploy_env_source }}") " && " (jinja "{{ item }}"))
      (args 
        (chdir (jinja "{{ rails_deploy_src }}")))
      (when "rails_deploy_pre_migrate_shell_commands and rails_deploy_git_location and rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed")
      (with_items (jinja "{{ rails_deploy_pre_migrate_shell_commands }}"))
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}"))
      (register "rails_deploy__register_migration_pre_commands")
      (changed_when "rails_deploy__register_migration_pre_commands.changed | bool"))
    (task "Migrate the database"
      (ansible.builtin.shell (jinja "{{ rails_deploy_env_source }}") " && bundle exec rake db:migrate")
      (args 
        (chdir (jinja "{{ rails_deploy_src }}")))
      (when "inventory_hostname == rails_deploy_hosts_master and (rails_deploy_database_force_migrate or (rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed and (rails_deploy_register_mtime_schema.stat.mtime != ansible_local.rails_deploy[rails_deploy_service].mtime.schema) or ansible_local.rails_deploy[rails_deploy_service].mtime.schema is undefined))")
      (register "rails_deploy_register_migration")
      (changed_when "rails_deploy_register_migration.changed | bool")
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}")))
    (task "Execute shell commands after migration"
      (ansible.builtin.shell (jinja "{{ rails_deploy_env_source }}") " && " (jinja "{{ item }}"))
      (args 
        (chdir (jinja "{{ rails_deploy_src }}")))
      (when "rails_deploy_post_migrate_shell_commands and rails_deploy_git_location and rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed")
      (with_items (jinja "{{ rails_deploy_post_migrate_shell_commands }}"))
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}"))
      (register "rails_deploy__register_migration_post_commands")
      (changed_when "rails_deploy__register_migration_post_commands.changed | bool"))
    (task "Reload the backend server"
      (ansible.builtin.service 
        (name (jinja "{{ rails_deploy_service }}"))
        (state "reloaded"))
      (when "rails_deploy_backend and (rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed and (inventory_hostname == rails_deploy_hosts_master or inventory_hostname != item) and not rails_deploy_register_migration is changed and rails_deploy_register_mtime_config.stat.mtime == ansible_local.rails_deploy[rails_deploy_service].mtime.config and not rails_deploy_backend_always_restart)")
      (delegate_to (jinja "{{ item }}"))
      (with_items (jinja "{{ groups[rails_deploy_hosts_group] }}")))
    (task "Restart the backend server"
      (ansible.builtin.service 
        (name (jinja "{{ rails_deploy_service }}"))
        (state "restarted"))
      (when "rails_deploy_backend and (rails_deploy_database_force_migrate or ((rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed) and rails_deploy_register_migration is changed) and (inventory_hostname == rails_deploy_hosts_master or inventory_hostname != item) or rails_deploy_register_mtime_config.stat.mtime != ansible_local.rails_deploy[rails_deploy_service].mtime.config or (rails_deploy_backend_always_restart and rails_deploy_git_location and rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed))")
      (delegate_to (jinja "{{ item }}"))
      (with_items (jinja "{{ groups[rails_deploy_hosts_group] }}")))
    (task "Set the extra services state"
      (ansible.builtin.service 
        (name (jinja "{{ item.name }}"))
        (state (jinja "{{ item.changed_state | default(\"reloaded\") }}")))
      (when "rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed and rails_deploy_extra_services")
      (with_items (jinja "{{ rails_deploy_extra_services }}")))
    (task "Set the initial backend server state"
      (ansible.builtin.service 
        (name (jinja "{{ rails_deploy_service }}"))
        (state (jinja "{{ rails_deploy_backend_state }}"))
        (enabled (jinja "{{ rails_deploy_backend_enabled }}")))
      (when "rails_deploy_git_location is defined and rails_deploy_git_location and rails_deploy_backend"))
    (task "Set the initial background worker state"
      (ansible.builtin.service 
        (name (jinja "{{ rails_deploy_worker }}"))
        (state (jinja "{{ rails_deploy_worker_state }}"))
        (enabled (jinja "{{ rails_deploy_worker_enabled }}")))
      (when "rails_deploy_worker_enabled and rails_deploy_git_location is defined and rails_deploy_git_location"))
    (task "Set the initial extra services state"
      (ansible.builtin.service 
        (name (jinja "{{ item.name }}"))
        (state (jinja "{{ item.state | default(\"started\") }}"))
        (enabled (jinja "{{ item.enabled | default(True) }}")))
      (when "rails_deploy_git_location is defined and rails_deploy_git_location and rails_deploy_extra_services")
      (with_items (jinja "{{ rails_deploy_extra_services }}")))
    (task "Execute shell commands after the backend is ready"
      (ansible.builtin.shell (jinja "{{ rails_deploy_env_source }}") " && " (jinja "{{ item }}") "  # noqa no-handler")
      (args 
        (chdir (jinja "{{ rails_deploy_src }}")))
      (when "rails_deploy_post_restart_shell_commands and rails_deploy_git_location and rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed")
      (with_items (jinja "{{ rails_deploy_post_restart_shell_commands }}"))
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}"))
      (register "rails_deploy__register_shell_commands")
      (changed_when "rails_deploy__register_shell_commands.changed | bool"))
    (task "Disable the temporary deploy page"
      (ansible.builtin.file 
        (path (jinja "{{ rails_deploy_src + \"/public/index.html\" }}"))
        (state "absent"))
      (when "rails_deploy_register_public_deploy_page.stat.exists and rails_deploy_register_repo_status is defined and rails_deploy_register_repo_status is changed")
      (changed_when "False")
      (become "True")
      (become_user (jinja "{{ rails_deploy_service }}")))))
