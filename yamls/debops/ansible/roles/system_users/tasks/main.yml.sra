(playbook "debops/ansible/roles/system_users/tasks/main.yml"
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
    (task "Gather local Ansible user details"
      (ansible.builtin.script "script/getent_passwd.py3 " (jinja "{{ system_users__self_name }}"))
      (register "system_users__register_passwd")
      (delegate_to "localhost")
      (become "False")
      (changed_when "False")
      (check_mode "False")
      (run_once "True")
      (when "system_users__self_name == lookup('env', 'USER')"))
    (task "Remember local Ansible user details"
      (ansible.builtin.set_fact 
        (system_users__fact_self_comment (jinja "{{ (system_users__register_passwd.stdout | from_json)[system_users__self_name][3] }}"))
        (system_users__fact_self_shell (jinja "{{ (system_users__register_passwd.stdout | from_json)[system_users__self_name][5] }}")))
      (when "system_users__self_name == lookup('env', 'USER')"))
    (task "Ensure that required packages are installed"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (system_users__base_packages
                              + system_users__shell_packages
                              + system_users__packages)) }}"))
        (state "present"))
      (register "system_users__register_packages")
      (until "system_users__register_packages is succeeded")
      (when "system_users__enabled | bool"))
    (task "Create UNIX groups for system users"
      (ansible.builtin.group 
        (name (jinja "{{ (item.prefix | d(system_users__prefix)) + (item.group | d(item.name)) }}"))
        (system (jinja "{{ item.system | d(False if (item.user | d(True)) | bool else True) }}"))
        (gid (jinja "{{ item.gid | d(omit) }}"))
        (state "present")
        (local (jinja "{{ True if (item.user | d(True)) | bool else False }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + (item.group | d(item.name)),
                \"state\": item.state | d(\"present\")} }}")))
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') not in ['absent', 'ignore'] and (item.private_group | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}")))
    (task "Gather information about existing remote users"
      (ansible.builtin.getent 
        (database "passwd")))
    (task "Manage UNIX accounts for system users"
      (ansible.builtin.user 
        (name (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}"))
        (group (jinja "{{ ((item.prefix | d(system_users__prefix)) + (item.group | d(item.name))) }}"))
        (home (jinja "{{ item.home
                            | d(((getent_passwd[(item.prefix | d(system_users__prefix)) + item.name][4])
                                 if (getent_passwd[(item.prefix | d(system_users__prefix)) + item.name] | d())
                                 else (system_users__home_root + \"/\" + ((item.prefix | d(system_users__prefix)) + item.name)))
                                if ((item.create_home | d(True)) | bool)
                                else omit) }}"))
        (uid (jinja "{{ item.uid | d(omit) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (comment (jinja "{{ item.comment | d(omit) }}"))
        (password (jinja "{{ item.password | d(\"*\") }}"))
        (update_password (jinja "{{ item.update_password | d(\"on_create\") }}"))
        (system (jinja "{{ item.system | d(omit) }}"))
        (shell (jinja "{{ item.shell | d(system_users__default_shell
                                           if system_users__default_shell | d()
                                           else omit) }}"))
        (create_home (jinja "{{ item.create_home | d(omit) }}"))
        (move_home (jinja "{{ item.move_home | d(omit) }}"))
        (skeleton (jinja "{{ item.skeleton | d(omit) }}"))
        (expires (jinja "{{ item.expires | d(omit) }}"))
        (remove (jinja "{{ item.remove | d(omit) }}"))
        (force (jinja "{{ item.force | d(omit) }}"))
        (non_unique (jinja "{{ item.non_unique | d(omit) }}"))
        (generate_ssh_key (jinja "{{ item.generate_ssh_key | d(omit) }}"))
        (ssh_key_bits (jinja "{{ item.ssh_key_bits | d(omit) }}"))
        (ssh_key_comment (jinja "{{ item.ssh_key_comment | d(omit) }}"))
        (ssh_key_file (jinja "{{ item.ssh_key_file | d(omit) }}"))
        (ssh_key_passphrase (jinja "{{ item.ssh_key_passphrase | d(omit) }}"))
        (ssh_key_type (jinja "{{ item.ssh_key_type | d(omit) }}"))
        (local (jinja "{{ item.local | d(True) }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"), \"gecos\": item.comment | d()} }}")))
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') not in ['ignore'] and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}")))
    (task "Gather information about existing remote groups"
      (ansible.builtin.getent 
        (database "group")))
    (task "Manage additional UNIX groups for system users"
      (ansible.builtin.user 
        (name (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}"))
        (groups (jinja "{{ (((([item.groups]
                    if (item.groups is string)
                    else item.groups)
                   if (item.groups is defined)
                   else [])
                  + (system_users__admin_groups
                     if ((item.admin | d()) | bool)
                     else []))
                 | intersect(getent_group.keys()))
                if (item.groups is defined or (item.admin | d()) | bool)
                else omit }}"))
        (append (jinja "{{ item.append | d(True) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (create_home (jinja "{{ item.create_home | d(omit) }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"), \"gecos\": item.comment | d(),
                \"groups\": item.groups | d()} }}")))
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') not in ['ignore'] and (item.groups | d() or (item.admin | d()) | bool) and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}")))
    (task "Manage system users home directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.home
              | d(((getent_passwd[(item.prefix | d(system_users__prefix)) + item.name][4])
                   if (getent_passwd[(item.prefix | d(system_users__prefix)) + item.name] | d())
                   else (system_users__home_root + \"/\" + ((item.prefix | d(system_users__prefix)) + item.name)))
                  if ((item.create_home | d(True)) | bool)
                  else omit) }}"))
        (state "directory")
        (owner (jinja "{{ item.home_owner | d(omit) }}"))
        (group (jinja "{{ item.home_group | d(omit) }}"))
        (mode (jinja "{{ item.home_mode | d(system_users__default_home_mode if (item.local | d(True)) | bool else omit) }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"),
                \"home\": (item.home | d(((getent_passwd[(item.prefix | d(system_users__prefix)) + item.name][4])
                                        if (getent_passwd[(item.prefix | d(system_users__prefix)) + item.name] | d())
                                        else (system_users__home_root + \"/\" + ((item.prefix | d(system_users__prefix)) + item.name)))
                                       if ((item.create_home | d(True)) | bool)
                                       else \"\"))} }}")))
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') not in ['absent', 'ignore'] and (item.create_home | d(True)) | bool and (item.home_owner | d() or item.home_group | d() or item.home_mode | d() or (item.local | d(True)) | bool) and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}")))
    (task "Manage system users home directory ACLs"
      (ansible.posix.acl 
        (path (jinja "{{ item.0.home
                     | d(((getent_passwd[(item.0.prefix | d(system_users__prefix)) + item.0.name][4])
                          if (getent_passwd[(item.0.prefix | d(system_users__prefix)) + item.0.name] | d())
                          else (system_users__home_root + \"/\" + ((item.0.prefix | d(system_users__prefix)) + item.0.name)))
                         if ((item.0.create_home | d(True)) | bool)
                         else omit) }}"))
        (default (jinja "{{ item.1.default | d(omit) }}"))
        (entity (jinja "{{ item.1.entity | d(omit) }}"))
        (entry (jinja "{{ item.1.entry | d(omit) }}"))
        (etype (jinja "{{ item.1.etype | d(omit) }}"))
        (permissions (jinja "{{ item.1.permissions | d(omit) }}"))
        (follow (jinja "{{ item.1.follow | d(omit) }}"))
        (recursive (jinja "{{ item.1.recursive | d(omit) }}"))
        (state (jinja "{{ item.1.state | d(\"present\") }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items
            | selectattr(\"home_acl\", \"defined\") | list
            | subelements(\"home_acl\") }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.0.prefix | d(system_users__prefix)) + item.0.name,
                \"state\": item.0.state | d(\"present\"), \"home_acl\": item.1} }}")))
      (when "(system_users__enabled | bool and system_users__acl_enabled | bool and item.0.name | d() and item.0.name != 'root' and item.0.state | d('present') not in ['absent', 'ignore'] and (item.0.create_home | d(True)) | bool and item.0.home_acl | d() and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.0.no_log) | d(True if item.0.password | d() else False) }}"))
      (tags (list
          "role::system_users:home_acl"
          "skip::system_users:home_acl"
          "skip::check")))
    (task "Allow specified system UNIX accounts to linger when not logged in"
      (ansible.builtin.command "loginctl enable-linger " (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}"))
      (args 
        (creates "/var/lib/systemd/linger/" (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"), \"linger\": item.linger | d(False)} }}")))
      (when "(system_users__enabled | bool and ansible_service_mgr == 'systemd' and item.name | d() and item.name != 'root' and item.state | d('present') not in ['absent', 'ignore'] and item.linger is defined and item.linger | bool and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}")))
    (task "Disallow specified UNIX accounts to linger when not logged in"
      (ansible.builtin.command "loginctl disable-linger " (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}"))
      (args 
        (removes "/var/lib/systemd/linger/" (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"), \"linger\": item.linger | d(False)} }}")))
      (when "(system_users__enabled | bool and ansible_service_mgr == 'systemd' and item.name | d() and item.name != 'root' and item.state | d('present') not in ['absent', 'ignore'] and item.linger is defined and not item.linger | bool and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}")))
    (task "Configure SSH authorized keys for system users"
      (ansible.posix.authorized_key 
        (key (jinja "{{ (item.sshkeys if item.sshkeys is string else '\\n'.join(item.sshkeys)) | string }}"))
        (state "present")
        (user (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}"))
        (exclusive (jinja "{{ item.sshkeys_exclusive | d(omit) }}"))
        (follow (jinja "{{ item.sshkeys_follow | d(omit) }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"), \"sshkeys\": item.sshkeys | d()} }}")))
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') not in ['absent', 'ignore'] and (item.create_home | d(True)) | bool and item.sshkeys | d() and item.sshkeys_state | d('present') != 'absent' and (item.user | d(True)) | bool and not ansible_check_mode)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}"))
      (tags (list
          "role::system_users:authorized_keys"
          "skip::system_users:authorized_keys"
          "skip::check")))
    (task "Remove SSH authorized keys from system user accounts if requested"
      (ansible.builtin.file 
        (path "~" (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}") "/.ssh/authorized_keys")
        (state "absent"))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"),
                \"sshkeys_state\": item.sshkeys_state | d(\"present\")} }}")))
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') not in ['absent', 'ignore'] and (item.create_home | d(True)) | bool and item.sshkeys | d() and item.sshkeys_state | d('present') == 'absent' and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}")))
    (task "Configure system user mail forwarding"
      (ansible.builtin.lineinfile 
        (dest "~/.forward")
        (regexp (jinja "{{ '^' + (item.forward if item.forward is string else item.forward[0]) }}"))
        (line (jinja "{{ item.forward if item.forward is string else item.forward | join(\", \") }}"))
        (state (jinja "{{ item.forward_state | d(\"present\") }}"))
        (create "True")
        (mode "0644"))
      (become "True")
      (become_user (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}"))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"),
                \"forward\": item.forward | d()} }}")))
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') not in ['absent', 'ignore'] and item.create_home | d(True) and item.forward | d() and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}"))
      (tags (list
          "role::system_users:forward"
          "skip::system_users:forward"
          "skip::check")))
    (task "Manage system users dotfiles"
      (ansible.builtin.shell "if ! yadm status > /dev/null ; then
    yadm clone --bootstrap \"" (jinja "{{ item.dotfiles_repo | d(system_users__dotfiles_repo) }}") "\"
else
    yadm pull
fi
")
      (environment 
        (LC_MESSAGES "C"))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\"),
                \"dotfiles\": (item.dotfiles | d(item.dotfiles_enabled | d(system_users__dotfiles_enabled))),
                \"dotfiles_repo\": ((item.dotfiles_repo | d(system_users__dotfiles_repo))
                                  if ((item.dotfiles | d(item.dotfiles_enabled | d(system_users__dotfiles_enabled))) | bool)
                                  else \"\")} }}")))
      (become "True")
      (become_user (jinja "{{ (item.prefix | d(system_users__prefix)) + item.name }}"))
      (check_mode "False")
      (register "system_users__register_dotfiles")
      (changed_when "('Already up to date.' not in system_users__register_dotfiles.stdout_lines | regex_replace('-', ' '))")
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') not in ['absent', 'ignore'] and (item.create_home | d(True)) | bool and (ansible_local | d() and ansible_local.yadm | d() and (ansible_local.yadm.installed | d()) | bool) and (item.dotfiles | d(item.dotfiles_enabled | d(system_users__dotfiles_enabled))) | bool and (item.dotfiles_repo | d(system_users__dotfiles_repo)) and (item.user | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}"))
      (tags (list
          "role::system_users:dotfiles"
          "skip::system_users:dotfiles"
          "skip::check")))
    (task "Manage system user resource directories"
      (ansible.builtin.file 
        (path (jinja "{{ \"~\" + (item.0.prefix | d(system_users__prefix)) + item.0.name + \"/\" + (item.1.path | d(item.1.dest | d(item.1))) }}"))
        (src (jinja "{{ item.1.src | d(omit) }}"))
        (state (jinja "{{ item.1.state | d(\"directory\") }}"))
        (owner (jinja "{{ item.1.owner | d((item.0.prefix | d(system_users__prefix)) + item.0.name) }}"))
        (group (jinja "{{ item.1.group | d((item.0.prefix | d(system_users__prefix)) + (item.0.group | d(item.0.name))) }}"))
        (mode (jinja "{{ item.1.mode | d(omit) }}"))
        (force (jinja "{{ item.1.force | d(omit) }}"))
        (recurse (jinja "{{ item.1.recurse | d(omit) }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items
            | selectattr(\"resources\", \"defined\") | list
            | subelements(\"resources\") }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": ((item.0.prefix | d(system_users__prefix)) + item.0.name),
                \"state\": item.0.state | d(\"present\"), \"resources\": item.1} }}")))
      (when "(system_users__enabled | bool and item.0.name | d() and item.0.name != 'root' and item.0.state | d('present') not in ['absent', 'ignore'] and item.0.create_home | d(True) and item.0.resources | d() and (item.0.user | d(True)) | bool and item.1.state | d('directory') in ['directory', 'link', 'touch'] and item.1.content is undefined)")
      (no_log (jinja "{{ debops__no_log | d(item.0.no_log) | d(True if item.0.password | d() else False) }}")))
    (task "Manage system user resource parent directories"
      (ansible.builtin.file 
        (path (jinja "{{ (\"~\" + (item.0.prefix | d(system_users__prefix)) + item.0.name + \"/\" + (item.1.path | d(item.1.dest))) | dirname }}"))
        (state "directory")
        (owner (jinja "{{ item.1.parent_owner | d((item.0.prefix | d(system_users__prefix)) + item.0.name) }}"))
        (group (jinja "{{ item.1.parent_group | d((item.0.prefix | d(system_users__prefix)) + (item.0.group | d(item.0.name))) }}"))
        (mode (jinja "{{ item.1.parent_mode | d(omit) }}"))
        (force (jinja "{{ item.1.force | d(omit) }}"))
        (recurse (jinja "{{ item.1.parent_recurse | d(omit) }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items
            | selectattr(\"resources\", \"defined\") | list
            | subelements(\"resources\") }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": ((item.0.prefix | d(system_users__prefix)) + item.0.name),
                \"state\": item.0.state | d(\"present\"), \"resources\": item.1} }}")))
      (when "(system_users__enabled | bool and item.0.name | d() and item.0.name != 'root' and item.0.state | d('present') not in ['absent', 'ignore'] and item.0.create_home | d(True) and item.0.resources | d() and (item.0.user | d(True)) | bool and item.1.state | d('directory') in ['present', 'file'])")
      (no_log (jinja "{{ debops__no_log | d(item.0.no_log) | d(True if item.0.password | d() else False) }}")))
    (task "Manage system user resource files"
      (ansible.builtin.copy 
        (dest (jinja "{{ \"~\" + (item.0.prefix | d(system_users__prefix)) + item.0.name + \"/\" + (item.1.path | d(item.1.dest)) }}"))
        (src (jinja "{{ item.1.src | d(omit) }}"))
        (content (jinja "{{ item.1.content | d(omit) }}"))
        (owner (jinja "{{ item.1.owner | d((item.0.prefix | d(system_users__prefix)) + item.0.name) }}"))
        (group (jinja "{{ item.1.group | d((item.0.prefix | d(system_users__prefix)) + (item.0.group | d(item.0.name))) }}"))
        (mode (jinja "{{ item.1.mode | d(omit) }}"))
        (force (jinja "{{ item.1.force | d(omit) }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items
            | selectattr(\"resources\", \"defined\") | list
            | subelements(\"resources\") }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": ((item.0.prefix | d(system_users__prefix)) + item.0.name),
                \"state\": item.0.state | d(\"present\"), \"resources\": item.1} }}")))
      (when "(system_users__enabled | bool and item.0.name | d() and item.0.name != 'root' and item.0.state | d('present') not in ['absent', 'ignore'] and item.0.create_home | d(True) and item.0.resources | d() and (item.0.user | d(True)) | bool and item.1.state | d('directory') in ['present', 'file'] and (item.1.dest | d() or item.1.path | d()) and (item.1.src | d() or item.1.content | d()))")
      (no_log (jinja "{{ debops__no_log | d(item.0.no_log) | d(True if item.0.password | d() else False) }}")))
    (task "Remove system user resources if requested"
      (ansible.builtin.file 
        (path (jinja "{{ \"~\" + (item.0.prefix | d(system_users__prefix)) + item.0.name + \"/\" + (item.1.path | d(item.1.dest | d(item.1))) }}"))
        (state "absent"))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items
            | selectattr(\"resources\", \"defined\") | list
            | subelements(\"resources\") }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": ((item.0.prefix | d(system_users__prefix)) + item.0.name),
                \"state\": item.0.state | d(\"present\"), \"resources\": item.1} }}")))
      (when "(system_users__enabled | bool and item.0.name | d() and item.0.name != 'root' and item.0.state | d('present') not in ['absent', 'ignore'] and item.0.create_home | d(True) and item.0.resources | d() and (item.0.user | d(True)) | bool and item.1.state | d('directory') == 'absent')")
      (no_log (jinja "{{ debops__no_log | d(item.0.no_log) | d(True if item.0.password | d() else False) }}")))
    (task "Remove user groups if requested"
      (ansible.builtin.group 
        (name (jinja "{{ (item.prefix | d(system_users__prefix)) + (item.group | d(item.name)) }}"))
        (state "absent")
        (local (jinja "{{ item.local | d(True if (item.user | d(True)) | bool else False) }}")))
      (loop (jinja "{{ system_users__combined_accounts | debops.debops.parse_kv_items }}"))
      (loop_control 
        (label (jinja "{{ {\"name\": (item.prefix | d(system_users__prefix)) + item.name,
                \"state\": item.state | d(\"present\")} }}")))
      (when "(system_users__enabled | bool and item.name | d() and item.name != 'root' and item.state | d('present') == 'absent' and (item.private_group | d(True)) | bool)")
      (no_log (jinja "{{ debops__no_log | d(item.no_log) | d(True if item.password | d() else False) }}")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save system users local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/system_users.fact.j2")
        (dest "/etc/ansible/facts.d/system_users.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
