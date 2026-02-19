(playbook "debops/ansible/roles/memcached/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install memcached"
      (ansible.builtin.package 
        (name (jinja "{{ (memcached__base_packages
               + memcached__packages) | flatten }}"))
        (state "present"))
      (register "memcached__register_packages")
      (until "memcached__register_packages is succeeded"))
    (task "Make sure that Ansible local facts directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Save memcached local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/memcached.fact.j2")
        (dest "/etc/ansible/facts.d/memcached.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Update Ansible facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))
    (task "Configure memcached"
      (ansible.builtin.template 
        (src "etc/memcached.conf.j2")
        (dest "/etc/memcached.conf")
        (mode "0644"))
      (notify (list
          "Restart memcached")))))
