(playbook "debops/ansible/roles/sysnews/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install packages required for System News"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (sysnews__base_packages
                              + sysnews__packages)) }}"))
        (state "present"))
      (register "sysnews__register_packages")
      (until "sysnews__register_packages is succeeded"))
    (task "Disable System News notification after login"
      (ansible.builtin.file 
        (path "/etc/profile.d/sysnews.sh")
        (state "absent"))
      (when "not sysnews__notification | bool"))
    (task "Configure System News notification after login"
      (ansible.builtin.template 
        (src "etc/profile.d/sysnews.sh.j2")
        (dest "/etc/profile.d/sysnews.sh")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "sysnews__notification | bool"))
    (task "Remove persistent news files"
      (ansible.builtin.file 
        (path "/var/lib/sysnews/" (jinja "{{ item.name }}"))
        (state "absent"))
      (with_items (jinja "{{ sysnews__combined_entries | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') == 'absent'"))
    (task "Generate persistent news files"
      (ansible.builtin.copy 
        (src (jinja "{{ item.src | d(omit) }}"))
        (content (jinja "{{ item.content | d(omit) }}"))
        (dest "/var/lib/sysnews/" (jinja "{{ item.name }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (jinja "{{ sysnews__combined_entries | debops.debops.parse_kv_items }}"))
      (when "item.name | d() and item.state | d('present') != 'absent'"))
    (task "Update list of persistent news files"
      (ansible.builtin.blockinfile 
        (content (jinja "{% for entry in sysnews__combined_entries | debops.debops.parse_kv_items %}") "
" (jinja "{{ entry.name }}") "
" (jinja "{% endfor %}") "
")
        (dest "/var/lib/sysnews/.noexpire")
        (create "True")
        (owner "root")
        (group (jinja "{{ sysnews__group }}"))
        (mode "0664")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save System News local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/sysnews.fact.j2")
        (dest "/etc/ansible/facts.d/sysnews.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
