(playbook "debops/ansible/roles/pgbadger/tasks/ssh_accounts.yml"
  (tasks
    (task "Create system UNIX group for remote pgBadger"
      (ansible.builtin.group 
        (name (jinja "{{ pgbadger__ssh_group }}"))
        (state "present")
        (system "True"))
      (delegate_to (jinja "{{ item }}")))
    (task "Create system UNIX account for remote pgBadger"
      (ansible.builtin.user 
        (name (jinja "{{ pgbadger__ssh_user }}"))
        (group (jinja "{{ pgbadger__ssh_group }}"))
        (groups (jinja "{{ pgbadger__ssh_additional_groups }}"))
        (append "True")
        (home (jinja "{{ pgbadger__ssh_home }}"))
        (comment (jinja "{{ pgbadger__comment }}"))
        (shell "/bin/bash")
        (state "present")
        (system "True"))
      (delegate_to (jinja "{{ item }}")))
    (task "Install public SSH key on remote host"
      (ansible.posix.authorized_key 
        (key (jinja "{{ pgbadger__register_ssh_public_key.content | b64decode }}"))
        (user (jinja "{{ pgbadger__ssh_user }}"))
        (state "present"))
      (delegate_to (jinja "{{ item }}")))
    (task "Scan SSH fingerprint of the remote host"
      (ansible.builtin.shell "ssh-keyscan -H -T 10 " (jinja "{{ hostvars[item][\"ansible_fqdn\"] }}") " 2>/dev/null")
      (changed_when "False")
      (check_mode "False")
      (become "True")
      (become_user (jinja "{{ pgbadger__ssh_user }}"))
      (register "pgbadger__register_ssh_keyscan"))
    (task "Register SSH host fingerprints on pgBadger host"
      (ansible.builtin.known_hosts 
        (key (jinja "{{ pgbadger__register_ssh_keyscan.stdout }}"))
        (name (jinja "{{ hostvars[item][\"ansible_fqdn\"] }}"))
        (hash_host "True")
        (state "present"))
      (become "True")
      (become_user (jinja "{{ pgbadger__ssh_user }}")))))
