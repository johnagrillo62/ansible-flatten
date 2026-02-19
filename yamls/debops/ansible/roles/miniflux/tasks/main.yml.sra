(playbook "debops/ansible/roles/miniflux/tasks/main.yml"
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
    (task "Create required UNIX system group"
      (ansible.builtin.group 
        (name (jinja "{{ miniflux__group }}"))
        (state "present")
        (system "True")))
    (task "Create required UNIX system account"
      (ansible.builtin.user 
        (name (jinja "{{ miniflux__user }}"))
        (group (jinja "{{ miniflux__group }}"))
        (home (jinja "{{ miniflux__home }}"))
        (comment (jinja "{{ miniflux__gecos }}"))
        (shell (jinja "{{ miniflux__shell }}"))
        (skeleton "/dev/null")
        (state "present")
        (system "True")))
    (task "Generate Miniflux configuration"
      (ansible.builtin.template 
        (src "etc/miniflux.conf.j2")
        (dest "/etc/miniflux.conf")
        (mode "0640"))
      (notify (list
          "Restart miniflux")))
    (task "Install systemd configuration files"
      (ansible.builtin.template 
        (src "etc/systemd/system/miniflux.service.j2")
        (dest "/etc/systemd/system/miniflux.service")
        (mode "0644"))
      (notify (list
          "Reload service manager"))
      (when "miniflux__upstream_type != 'apt'"))
    (task "Flush handlers if needed"
      (ansible.builtin.meta "flush_handlers"))
    (task "Start and enable Miniflux service"
      (ansible.builtin.service 
        (name "miniflux")
        (state "started")
        (enabled "True"))
      (when "miniflux__upstream_type != 'apt'"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Minflux local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/miniflux.fact.j2")
        (dest "/etc/ansible/facts.d/miniflux.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))))
