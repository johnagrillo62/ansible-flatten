(playbook "debops/ansible/roles/pdns/tasks/main.yml"
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
    (task "Ensure PowerDNS support is installed"
      (ansible.builtin.package 
        (name (jinja "{{ (pdns__base_packages + pdns__packages) | flatten }}"))
        (state "present"))
      (register "pdns__register_packages")
      (until "pdns__register_packages is succeeded"))
    (task "Configure PostgreSQL"
      (ansible.builtin.include_tasks "init_postgresql.yml")
      (when "('gpgsql' in pdns__backends)"))
    (task "Divert original configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/powerdns/pdns.conf")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/pdns.fact.j2")
        (dest "/etc/ansible/facts.d/pdns.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Configure local PowerDNS changes"
      (ansible.builtin.template 
        (src "etc/powerdns/pdns.conf.j2")
        (dest "/etc/powerdns/pdns.conf")
        (owner "root")
        (group "pdns")
        (mode "0640"))
      (notify (list
          "Restart pdns")))))
