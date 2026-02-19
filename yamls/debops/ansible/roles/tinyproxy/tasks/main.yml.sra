(playbook "debops/ansible/roles/tinyproxy/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required APT packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", tinyproxy__base_packages
                             + tinyproxy__packages) }}"))
        (state "present"))
      (register "tinyproxy__register_packages")
      (until "tinyproxy__register_packages is succeeded")
      (notify (list
          "Restart tinyproxy")))
    (task "Create required UNIX system group"
      (ansible.builtin.group 
        (name (jinja "{{ tinyproxy__group }}"))
        (state "present")
        (system "True")))
    (task "Make sure that required UNIX account exists"
      (ansible.builtin.user 
        (name (jinja "{{ tinyproxy__user }}"))
        (group (jinja "{{ tinyproxy__group }}"))
        (home (jinja "{{ tinyproxy__home }}"))
        (comment "Tinyproxy daemon")
        (shell "/bin/false")
        (state "present")
        (system "True")))
    (task "Divert the original tinyproxy configuration file"
      (debops.debops.dpkg_divert 
        (path (jinja "{{ tinyproxy__configuration_file }}"))
        (state "present")
        (delete "True")))
    (task "Generate tinyproxy configuration"
      (ansible.builtin.template 
        (src "etc/tinyproxy/tinyproxy.conf.j2")
        (dest (jinja "{{ tinyproxy__configuration_file }}"))
        (mode "0644"))
      (notify (list
          "Restart tinyproxy")))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save Tinyproxy local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/tinyproxy.fact.j2")
        (dest "/etc/ansible/facts.d/tinyproxy.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
