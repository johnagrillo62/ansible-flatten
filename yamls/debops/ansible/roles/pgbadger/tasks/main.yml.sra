(playbook "debops/ansible/roles/pgbadger/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install pgBadger APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", pgbadger__base_packages
                             + pgbadger__packages) }}"))
        (state "present"))
      (register "pgbadger__register_packages")
      (until "pgbadger__register_packages is succeeded"))
    (task "Create system UNIX group for pgBadger"
      (ansible.builtin.group 
        (name (jinja "{{ pgbadger__group }}"))
        (state "present")
        (system "True")))
    (task "Create system UNIX account for pgBadger"
      (ansible.builtin.user 
        (name (jinja "{{ pgbadger__user }}"))
        (group (jinja "{{ pgbadger__group }}"))
        (groups (jinja "{{ pgbadger__additional_groups }}"))
        (home (jinja "{{ pgbadger__home }}"))
        (comment (jinja "{{ pgbadger__comment }}"))
        (shell "/bin/bash")
        (state "present")
        (system "True")
        (generate_ssh_key "True")))
    (task "Create webroot directory for pgBadger"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "directory")
        (owner (jinja "{{ pgbadger__user }}"))
        (group (jinja "{{ pgbadger__group }}"))
        (mode "0755"))
      (loop (list
          (jinja "{{ pgbadger__www_root }}")
          (jinja "{{ pgbadger__scripts_path }}"))))
    (task "Get pgBadger SSH public key from its account"
      (ansible.builtin.slurp 
        (src (jinja "{{ pgbadger__ssh_public_key_file }}")))
      (register "pgbadger__register_ssh_public_key")
      (when "pgbadger__ssh_accounts_enabled | bool")
      (tags (list
          "role::pgbadger:ssh")))
    (task "Gather facts from remote hosts"
      (ansible.builtin.setup 
        (gather_subset "!all")
        (fact_path "/dev/null"))
      (delegate_facts "True")
      (delegate_to (jinja "{{ item }}"))
      (loop (jinja "{{ groups[pgbadger__ssh_inventory_group] }}"))
      (when "pgbadger__ssh_accounts_enabled | bool and pgbadger__ssh_inventory_group in groups")
      (tags (list
          "role::pgbadger:ssh")))
    (task "Set up remote SSH access for pgBadger"
      (ansible.builtin.include_tasks 
        (file "ssh_accounts.yml")
        (apply 
          (tags (list
              "role::pgbadger:ssh"))))
      (loop (jinja "{{ groups[pgbadger__ssh_inventory_group] }}"))
      (when "pgbadger__ssh_accounts_enabled | bool and pgbadger__ssh_inventory_group in groups and item != inventory_hostname")
      (tags (list
          "role::pgbadger:ssh")))
    (task "Verify that all required parameters are present"
      (ansible.builtin.assert 
        (that (list
            "item.name is defined and item.name is truthy"
            "(item.host is defined and item.host is truthy) or (item.raw is defined)"
            "(item.output is defined and item.output is truthy) or (item.raw is defined)"))
        (quiet "True"))
      (loop (jinja "{{ pgbadger__combined_instances | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}"))))
    (task "Remove pgBadger instance scripts when requested"
      (ansible.builtin.file 
        (path (jinja "{{ pgbadger__scripts_path + \"/\" + item.name }}"))
        (state "absent"))
      (loop (jinja "{{ pgbadger__combined_instances | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (when "(item.state | d('present')) in [ 'absent' ]"))
    (task "Generate pgBadger instance scripts"
      (ansible.builtin.template 
        (src "home/scripts/instance.j2")
        (dest (jinja "{{ pgbadger__scripts_path + \"/\" + item.name }}"))
        (owner (jinja "{{ pgbadger__user }}"))
        (group (jinja "{{ pgbadger__group }}"))
        (mode "0755"))
      (loop (jinja "{{ pgbadger__combined_instances | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": item.name, \"state\": item.state} }}")))
      (when "(item.state | d('present')) not in [ 'absent', 'ignore', 'init' ]"))
    (task "Manage pgBadger cron entry"
      (ansible.builtin.cron 
        (name "Execute pgbadger scripts")
        (special_time (jinja "{{ pgbadger__cron_interval }}"))
        (state (jinja "{{ pgbadger__cron_deploy_state }}"))
        (user (jinja "{{ pgbadger__user }}"))
        (job "run-parts " (jinja "{{ pgbadger__scripts_path }}"))))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save pgbadger local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/pgbadger.fact.j2")
        (dest "/etc/ansible/facts.d/pgbadger.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
