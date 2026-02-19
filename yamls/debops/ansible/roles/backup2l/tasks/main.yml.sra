(playbook "debops/ansible/roles/backup2l/tasks/main.yml"
  (tasks
    (task "Import DebOps secret role"
      (ansible.builtin.import_role 
        (name "secret")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (backup2l__base_packages
                              + backup2l__packages)) }}"))
        (state "present")))
    (task "Divert the original backup2l config file"
      (debops.debops.dpkg_divert 
        (path "/etc/backup2l.conf")))
    (task "Create required directories"
      (ansible.builtin.file 
        (path (jinja "{{ item.path }}"))
        (state "directory")
        (mode (jinja "{{ item.mode | d(\"0755\") }}")))
      (with_items (list
          
          (path (jinja "{{ backup2l__backup_dir }}"))
          (mode "0750")
          
          (path (jinja "{{ backup2l__pre_hook_dir }}"))
          
          (path (jinja "{{ backup2l__post_hook_dir }}")))))
    (task "Install pre-hook scripts"
      (ansible.builtin.copy 
        (src "usr/local/etc/backup/pre-hook.d/")
        (dest (jinja "{{ backup2l__pre_hook_dir }}") "/")
        (mode "0755")))
    (task "Add paths to backup in an include file"
      (ansible.builtin.lineinfile 
        (dest (jinja "{{ backup2l__include_file }}"))
        (regexp "^" (jinja "{{ item.path | d(item) }}") "$")
        (line (jinja "{{ item.path | d(item) }}"))
        (state (jinja "{{ item.state | d(\"present\") }}"))
        (create "True")
        (mode "0644"))
      (loop (jinja "{{ q(\"flattened\", backup2l__default_include
                           + backup2l__include
                           + backup2l__group_include
                           + backup2l__host_include) }}"))
      (when "backup2l__srclist_from_file | bool"))
    (task "Generate backup2l configuration"
      (ansible.builtin.template 
        (src "etc/backup2l.conf.j2")
        (dest "/etc/backup2l.conf")
        (mode "0644")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save backup2l local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/backup2l.fact.j2")
        (dest "/etc/ansible/facts.d/backup2l.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
