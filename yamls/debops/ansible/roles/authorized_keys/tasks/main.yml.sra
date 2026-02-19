(playbook "debops/ansible/roles/authorized_keys/tasks/main.yml"
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
    (task "Ensure that SSH identity datastore exists"
      (ansible.builtin.file 
        (path (jinja "{{ authorized_keys__path }}"))
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755"))
      (when "authorized_keys__enabled | bool"))
    (task "Ensure the required groups exist"
      (ansible.builtin.group 
        (name (jinja "{{ item.group }}"))
        (gid (jinja "{{ item.gid | d(omit) }}"))
        (system (jinja "{{ item.system | bool }}"))
        (state "present"))
      (loop (jinja "{{ lookup(\"template\", \"lookup/authorized_keys__identities.j2\") | from_yaml }}"))
      (loop_control 
        (label (jinja "{{ {\"identity\": item.identity, \"group\": item.group} }}")))
      (when "authorized_keys__enabled | bool and item.group | d() and item.state | d('present') not in ['absent', 'ignore', 'init'] and item.file_state | d('present') not in ['absent', 'ignore', 'init']"))
    (task "Get list of all groups"
      (ansible.builtin.getent 
        (database "group")
        (split ":"))
      (when "authorized_keys__enabled | bool"))
    (task "Get list of all users"
      (ansible.builtin.getent 
        (database "passwd")
        (split ":"))
      (when "authorized_keys__enabled | bool"))
    (task "Configure authorized keys for users"
      (ansible.posix.authorized_key 
        (key (jinja "{{ item.key }}"))
        (user (jinja "{{ item.user if (item.home | d()) | bool else \"root\" }}"))
        (manage_dir (jinja "{{ item.manage_dir }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (key_options (jinja "{{ item.key_options | d(omit) }}"))
        (comment (jinja "{{ item.comment | d(omit) }}"))
        (path (jinja "{{ item.path | d(omit) }}"))
        (exclusive (jinja "{{ item.exclusive | d(omit) }}"))
        (follow (jinja "{{ item.follow | d(omit) }}")))
      (loop (jinja "{{ lookup(\"template\", \"lookup/authorized_keys__identities.j2\") | from_yaml }}"))
      (loop_control 
        (label (jinja "{{ {\"identity\": item.identity,
                \"state\": (item.state | d(\"present\")
                          if (item.user in getent_passwd.keys() and (item.home | d()) | bool)
                          else (\"no user\"
                                if (item.user not in getent_passwd.keys() and (item.home | d()) | bool)
                                else item.state | d(\"present\"))),
                \"user\": item.user,
                \"path\": item.path | d(\"~\" + item.user + \"/.ssh/authorized_keys\")} }}")))
      (when "(authorized_keys__enabled | bool and item.file_state | d('present') != 'absent' and ((item.home | d()) | bool and item.user in getent_passwd.keys()) or not (item.home | d()) | bool)"))
    (task "Enforce state of authorized_keys user files"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (owner (jinja "{{ item.owner if (item.owner | d() and item.owner in getent_passwd.keys()) else \"root\" }}"))
        (group (jinja "{{ (item.group
                if (item.group | d() and item.group in (getent_group | d({})).keys())
                else (getent_passwd[item.owner][2] | d({})
                      if (item.owner in getent_passwd | d({}))
                      else omit)) }}"))
        (mode (jinja "{{ item.mode }}"))
        (state (jinja "{{ \"absent\" if (item.file_state | d(\"present\") == \"absent\") else omit }}")))
      (loop (jinja "{{ lookup(\"template\", \"lookup/authorized_keys__identities.j2\") | from_yaml }}"))
      (loop_control 
        (label (jinja "{{ {\"identity\": item.identity,
                \"state\": item.file_state | d(\"present\"),
                \"group\": (item.group
                          if (item.group | d() and item.group in (getent_group | d({})).keys())
                          else (getent_passwd[item.owner | d(\"root\")][2] | d({})
                                if (item.owner | d(\"root\") in getent_passwd | d({}))
                                else \"root\")),
                \"path\": item.path} }}")))
      (when "authorized_keys__enabled | bool and item.path | d() and not item.manage_dir | bool and item.state | d('present') not in ['absent', 'ignore', 'init'] and not ansible_check_mode"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save authorized_keys local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/authorized_keys.fact.j2")
        (dest "/etc/ansible/facts.d/authorized_keys.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Re-read local facts if they have been modified"
      (ansible.builtin.meta "flush_handlers"))))
