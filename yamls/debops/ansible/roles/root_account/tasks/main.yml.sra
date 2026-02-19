(playbook "debops/ansible/roles/root_account/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Ensure that required packages are installed"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (root_account__base_packages
                              + root_account__shell_packages
                              + root_account__packages)) }}"))
        (state "present"))
      (register "root_account__register_packages")
      (until "root_account__register_packages is succeeded")
      (when "root_account__enabled | bool"))
    (task "Check available SSH key types"
      (ansible.builtin.shell "ssh -Q key 2>/dev/null || echo \"ssh-rsa\"")
      (register "root_account__register_key_types")
      (changed_when "False")
      (check_mode "False")
      (tags (list
          "meta::facts")))
    (task "Check if preferred shell exists"
      (ansible.builtin.stat 
        (path (jinja "{{ root_account__shell }}")))
      (register "root_account__register_shell")
      (when "root_account__enabled | bool and root_account__shell | d(False)"))
    (task "Fail if setting a shell that does not exist"
      (ansible.builtin.fail 
        (msg "Trying to set a shell that does not exist, this can lock you out!"))
      (when "root_account__enabled | bool and root_account__shell | d(False) and not root_account__register_shell.stat.exists and not ansible_check_mode"))
    (task "Enforce root system group"
      (ansible.builtin.group 
        (name "root")
        (gid "0")
        (system "True")
        (state "present"))
      (when "root_account__enabled | bool"))
    (task "Enforce root system account"
      (ansible.builtin.user 
        (name "root")
        (state "present")
        (home "/root")
        (uid "0")
        (groups "")
        (append "False")
        (system "True")
        (group (jinja "{{ root_account__group }}"))
        (generate_ssh_key (jinja "{{ root_account__generate_ssh_key | bool }}"))
        (ssh_key_bits (jinja "{{ root_account__ssh_key_bits }}"))
        (ssh_key_type (jinja "{{ root_account__ssh_key_type }}"))
        (ssh_key_file (jinja "{{ root_account__ssh_key_file }}"))
        (ssh_key_comment (jinja "{{ root_account__ssh_key_comment }}"))
        (update_password (jinja "{{ \"always\" if root_account__password_update | bool else \"on_create\" }}"))
        (password (jinja "{{ root_account__password if root_account__password else omit }}"))
        (shell (jinja "{{ root_account__shell if root_account__shell else omit }}")))
      (when "root_account__enabled | bool")
      (no_log (jinja "{{ (debops__no_log | d(True)) if root_account__password else False }}")))
    (task "Enforce root home permissions"
      (ansible.builtin.file 
        (path "/root")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0700"))
      (when "root_account__enabled | bool"))
    (task "Configure authorized SSH keys for root account"
      (ansible.posix.authorized_key 
        (key (jinja "{{ q('flattened', root_account__combined_authorized_keys)
              | join('\\n') }}"))
        (exclusive (jinja "{{ root_account__authorized_keys_exclusive | bool }}"))
        (state "present")
        (user "root")
        (follow (jinja "{{ root_account__authorized_keys_follow | bool }}")))
      (when "root_account__enabled | bool and root_account__authorized_keys_state != 'absent'"))
    (task "Remove /root/.ssh/authorized_keys file if requested"
      (ansible.builtin.file 
        (path "/root/.ssh/authorized_keys")
        (state "absent"))
      (when "root_account__enabled | bool and root_account__authorized_keys_state == 'absent'"))
    (task "Check subuid presence for root account"
      (ansible.builtin.shell "grep -E '^root:' /etc/subuid || true")
      (register "root_account__register_subuid")
      (check_mode "False")
      (changed_when "False")
      (when "root_account__enabled | bool and root_account__subuid_enabled | bool"))
    (task "Add subuids and subgids for root account"
      (ansible.builtin.command "usermod --add-subuids " (jinja "{{ (item | string + \"-\" + (item | int + root_account__subuid_count | int) | string) }}") " --add-subgids " (jinja "{{ (item | string + \"-\" + (item | int + root_account__subuid_count | int) | string) }}") " root")
      (with_items (jinja "{{ root_account__subuid_start }}"))
      (register "root_account__register_usermod")
      (changed_when "root_account__register_usermod.changed | bool")
      (when "root_account__enabled | bool and root_account__subuid_enabled | bool and not root_account__register_subuid.stdout | d()"))
    (task "Manage root dotfiles"
      (ansible.builtin.shell "if ! yadm status > /dev/null ; then
    yadm clone --bootstrap \"" (jinja "{{ root_account__dotfiles_repo }}") "\"
else
    yadm pull
fi
")
      (environment 
        (LC_MESSAGES "C"))
      (register "root_account__register_dotfiles")
      (changed_when "('Already up to date.' not in root_account__register_dotfiles.stdout_lines | regex_replace('-', ' '))")
      (when "((ansible_local | d() and ansible_local.yadm | d() and (ansible_local.yadm.installed | d()) | bool) and root_account__dotfiles_enabled | bool)")
      (check_mode "False"))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Setup root account local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/root_account.fact.j2")
        (dest "/etc/ansible/facts.d/root_account.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
