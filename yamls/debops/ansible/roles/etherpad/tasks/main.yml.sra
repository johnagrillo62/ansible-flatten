(playbook "debops/ansible/roles/etherpad/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Install required Etherpad packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (etherpad__base_packages
                              + (etherpad__document_packages
                                 if etherpad_abiword | bool
                                 else [])
                              + etherpad__packages)) }}"))
        (state "present"))
      (register "etherpad__register_packages")
      (until "etherpad__register_packages is succeeded"))
    (task "Create Etherpad system group"
      (ansible.builtin.group 
        (name (jinja "{{ etherpad_group }}"))
        (system "yes")
        (state "present")))
    (task "Create Etherpad user"
      (ansible.builtin.user 
        (name (jinja "{{ etherpad_user }}"))
        (group (jinja "{{ etherpad_group }}"))
        (home (jinja "{{ etherpad_home }}"))
        (shell (jinja "{{ etherpad__shell }}"))
        (comment "Etherpad")
        (system "yes")
        (state "present")))
    (task "Create Etherpad source directory"
      (ansible.builtin.file 
        (path (jinja "{{ etherpad_src_dir }}"))
        (state "directory")
        (owner (jinja "{{ etherpad_user }}"))
        (group (jinja "{{ etherpad_group }}"))
        (mode "0750")))
    (task "Secure Etherpad home directory"
      (ansible.builtin.file 
        (path (jinja "{{ etherpad_home }}"))
        (state "directory")
        (owner (jinja "{{ etherpad_user }}"))
        (group (jinja "{{ etherpad_group }}"))
        (mode "0750")))
    (task "Clone Etherpad source code"
      (ansible.builtin.git 
        (repo (jinja "{{ etherpad_source_address + \"/\" + etherpad_repository }}"))
        (dest (jinja "{{ etherpad_src_dir + \"/\" + etherpad_repository }}"))
        (version (jinja "{{ etherpad_version }}"))
        (bare "yes")
        (update "yes"))
      (become "True")
      (become_user (jinja "{{ etherpad_user }}"))
      (register "etherpad_register_source")
      (tags (list
          "role::etherpad:source")))
    (task "Check if Etherpad is checked out"
      (ansible.builtin.stat 
        (path (jinja "{{ etherpad_home + \"/\" + etherpad_repository }}")))
      (register "etherpad_register_directory")
      (tags (list
          "role::etherpad:source")))
    (task "Create Etherpad directory"
      (ansible.builtin.file 
        (path (jinja "{{ etherpad_home + \"/\" + etherpad_repository }}"))
        (state "directory")
        (owner (jinja "{{ etherpad_user }}"))
        (group (jinja "{{ etherpad_group }}"))
        (mode "0755"))
      (when "(etherpad_register_source is defined and etherpad_register_source is changed) or (etherpad_register_directory is defined and not etherpad_register_directory.stat.exists | bool)")
      (tags (list
          "role::etherpad:source")))
    (task "Prepare Etherpad worktree"
      (ansible.builtin.template 
        (src "var/local/etherpad-lite/etherpad-lite/git.j2")
        (dest (jinja "{{ etherpad_home + \"/\" + etherpad_repository }}") "/.git")
        (owner (jinja "{{ etherpad_user }}"))
        (group (jinja "{{ etherpad_group }}"))
        (mode "0644"))
      (when "(etherpad_register_source is defined and etherpad_register_source is changed) or (etherpad_register_directory is defined and not etherpad_register_directory.stat.exists | bool)")
      (tags (list
          "role::etherpad:source")))
    (task "Checkout Etherpad"
      (ansible.builtin.command "git checkout --force " (jinja "{{ etherpad_version }}"))
      (args 
        (chdir (jinja "{{ etherpad_src_dir + \"/\" + etherpad_repository }}")))
      (environment 
        (GIT_WORK_TREE (jinja "{{ etherpad_home + \"/\" + etherpad_repository }}")))
      (become "True")
      (become_user (jinja "{{ etherpad_user }}"))
      (register "etherpad_register_checkout")
      (notify (list
          "Restart etherpad-lite"))
      (changed_when "etherpad_register_checkout.changed | bool")
      (when "(etherpad_register_source is defined and etherpad_register_source is changed) or (etherpad_register_directory is defined and not etherpad_register_directory.stat.exists | bool)")
      (tags (list
          "role::etherpad:source")))
    (task "Generate Etherpad session key"
      (ansible.builtin.set_fact 
        (etherpad_session_key (jinja "{{ lookup(\"password\", secret + \"/credentials/\" + ansible_fqdn
                              + \"/etherpad/session_key chars=ascii_letters,numbers,digits,hexdigits length=30\") }}")))
      (when "secret is defined and secret"))
    (task "Generate Etherpad configuration"
      (ansible.builtin.template 
        (src "var/local/etherpad-lite/etherpad-lite/settings.json.j2")
        (dest (jinja "{{ etherpad_home + \"/\" + etherpad_repository }}") "/settings.json")
        (owner (jinja "{{ etherpad_user }}"))
        (group (jinja "{{ etherpad_group }}"))
        (mode "0644"))
      (notify (list
          "Restart etherpad-lite"))
      (tags (list
          "role::etherpad:config")))
    (task "Create log directory"
      (ansible.builtin.file 
        (path "/var/log/etherpad-lite")
        (state "directory")
        (owner (jinja "{{ etherpad_user }}"))
        (group "adm")
        (mode "0755")))
    (task "Install Etherpad dependencies"
      (ansible.builtin.command "bin/installDeps.sh")
      (args 
        (chdir (jinja "{{ etherpad_home + \"/\" + etherpad_repository }}"))
        (creates (jinja "{{ etherpad_home }}") "/.node-gyp"))
      (become "True")
      (become_user (jinja "{{ etherpad_user }}"))
      (when "etherpad_register_checkout is changed"))
    (task "Manage Etherpad plugins"
      (community.general.npm 
        (name (jinja "{{ item.name | d(item) }}"))
        (path (jinja "{{ etherpad_home + \"/\" + etherpad_repository }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (production "yes"))
      (loop (jinja "{{ q(\"flattened\", etherpad__default_plugins
                           + etherpad_plugins) }}"))
      (become "True")
      (become_user (jinja "{{ etherpad_user }}"))
      (notify (list
          "Restart etherpad-lite"))
      (tags (list
          "role::etherpad:plugins")))
    (task "Configure etherpad-lite system service"
      (ansible.builtin.template 
        (src "etc/default/etherpad-lite.j2")
        (dest "/etc/default/etherpad-lite")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "ansible_service_mgr != 'systemd'"))
    (task "Install etherpad-lite init script"
      (ansible.builtin.template 
        (src "etc/init.d/etherpad-lite.j2")
        (dest "/etc/init.d/etherpad-lite")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Reload service manager"))
      (register "etherpad__register_sysvinit")
      (when "ansible_service_mgr != 'systemd'"))
    (task "Install etherpad-lite systemd unit"
      (ansible.builtin.template 
        (src "etc/systemd/system/etherpad-lite.service.j2")
        (dest "/etc/systemd/system/etherpad-lite.service")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload service manager"))
      (register "etherpad__register_systemd")
      (when "ansible_service_mgr == 'systemd'"))
    (task "Reload systemd daemons"
      (ansible.builtin.meta "flush_handlers"))
    (task "Ensure that etherpad-lite is started"
      (ansible.builtin.service 
        (name "etherpad-lite")
        (state "started")
        (enabled "True"))
      (when "(etherpad__register_sysvinit is changed or etherpad__register_systemd is changed)"))
    (task "Wait for the API key file generation"
      (ansible.builtin.wait_for 
        (path (jinja "{{ etherpad_api_key_file }}"))
        (timeout "30")))
    (task "Wait for Etherpad application port to be reachable"
      (ansible.builtin.wait_for 
        (port (jinja "{{ etherpad_port }}"))
        (timeout "30")))
    (task "Get the generated API key"
      (ansible.builtin.command "cat " (jinja "{{ etherpad_api_key_file }}"))
      (register "etherpad_api_key")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "role::etherpad:api"
          "role::etherpad:api:call")))
    (task "Make API calls"
      (ansible.builtin.uri 
        (url "http://localhost:" (jinja "{{ etherpad_port }}") "/api/" (jinja "{{ etherpad_api_version }}") "/" (jinja "{{ item.method }}") "?apikey=" (jinja "{{
          etherpad_api_key.stdout }}") (jinja "{% if item.args | d() %}") (jinja "{% for key, value in item.args.items() %}") (jinja "{{
          \"&\" + key + \"=\" + value }}") (jinja "{% endfor %}") (jinja "{% endif %}")))
      (register "etherpad_api_calls_exec")
      (with_items (jinja "{{ etherpad_api_calls }}"))
      (no_log (jinja "{{ debops__no_log | d(True) }}"))
      (tags (list
          "role::etherpad:api"
          "role::etherpad:api:call")))
    (task "Display API call responses for debugging"
      (ansible.builtin.debug 
        (var "etherpad_api_calls_exec"))
      (when "etherpad_api_calls_exec | d() and etherpad_api_calls_debug")
      (tags (list
          "role::etherpad:api"
          "role::etherpad:api:call")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save Etherpad local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/etherpad.fact.j2")
        (dest "/etc/ansible/facts.d/etherpad.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
