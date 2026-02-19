(playbook "debops/ansible/roles/minidlna/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install MiniDLNA packages"
      (ansible.builtin.apt 
        (name (jinja "{{ (minidlna__base_packages + minidlna__packages) | flatten }}"))
        (state "present"))
      (register "minidlna__register_packages")
      (until "minidlna__register_packages is succeeded"))
    (task "Divert the MiniDLNA configuration file"
      (debops.debops.dpkg_divert 
        (path "/etc/minidlna.conf")))
    (task "Generate MiniDLNA configuration file"
      (ansible.builtin.template 
        (src "etc/minidlna.conf.j2")
        (dest "/etc/minidlna.conf")
        (owner "root")
        (group "root")
        (mode "0644")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (register "minidlna__register_configuration"))
    (task "Conditionally restart MiniDLNA service"
      (ansible.builtin.systemd 
        (name "minidlna.service")
        (enabled "true")
        (daemon_reload (jinja "{{ True if (minidlna__register_configuration is changed) else omit }}"))
        (state (jinja "{{ \"restarted\" if (minidlna__register_configuration is changed) else \"started\" }}")))
      (when "ansible_service_mgr == 'systemd'"))
    (task "Make sure that Ansible local fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Create local facts of MiniDLNA"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/minidlna.fact.j2")
        (dest "/etc/ansible/facts.d/minidlna.fact")
        (owner "root")
        (group "root")
        (mode "0755")
        (unsafe_writes (jinja "{{ True if (core__unsafe_writes | d(ansible_local.core.unsafe_writes | d()) | bool) else omit }}")))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
