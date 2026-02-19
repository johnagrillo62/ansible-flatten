(playbook "debops/ansible/roles/etc_aliases/tasks/main.yml"
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
    (task "Check if the dependent recipients file exists"
      (ansible.builtin.stat 
        (path (jinja "{{ secret + \"/etc_aliases/dependent_config/\" + inventory_hostname + \"/recipients.json\" }}")))
      (register "etc_aliases__register_dependent_recipients_file")
      (become "False")
      (delegate_to "localhost")
      (when "(ansible_local | d() and ansible_local.etc_aliases | d() and ansible_local.etc_aliases.configured is defined and ansible_local.etc_aliases.configured | bool)"))
    (task "Load the dependent recipients from Ansible Controller"
      (ansible.builtin.slurp 
        (src (jinja "{{ secret + \"/etc_aliases/dependent_config/\" + inventory_hostname + \"/recipients.json\" }}")))
      (register "etc_aliases__register_dependent_recipients")
      (become "False")
      (delegate_to "localhost")
      (when "(ansible_local | d() and ansible_local.etc_aliases | d() and ansible_local.etc_aliases.configured is defined and ansible_local.etc_aliases.configured | bool and etc_aliases__register_dependent_recipients_file.stat.exists | bool)"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Save etc_aliases local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/etc_aliases.fact.j2")
        (dest "/etc/ansible/facts.d/etc_aliases.fact")
        (owner "root")
        (group "root")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Generate the /etc/aliases file"
      (ansible.builtin.template 
        (src "etc/aliases.j2")
        (dest "/etc/aliases")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Update /etc/aliases.db database")))
    (task "Save etc_aliases dependent recipients on Ansible Controller"
      (ansible.builtin.template 
        (src "secret/etc_aliases/dependent_config/inventory_hostname/recipients.json.j2")
        (dest (jinja "{{ secret + \"/etc_aliases/dependent_config/\" + inventory_hostname + \"/recipients.json\" }}"))
        (mode "0644"))
      (become "False")
      (delegate_to "localhost")
      (when "etc_aliases__dependent_recipients | length > 0"))))
