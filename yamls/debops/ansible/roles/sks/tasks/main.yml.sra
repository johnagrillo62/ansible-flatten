(playbook "debops/ansible/roles/sks/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install SKS Keyserver"
      (ansible.builtin.apt 
        (name "sks")
        (state "present")
        (install_recommends "no"))
      (register "sks__register_packages")
      (until "sks__register_packages is succeeded"))
    (task "Configure firewall for SKS Keyserver"
      (ansible.builtin.template 
        (src "etc/ferm/filter-input.d/sks.conf.j2")
        (dest "/etc/ferm/filter-input.d/sks.conf")
        (owner "root")
        (group "adm")
        (mode "0644"))
      (notify (list
          "Restart ferm")))
    (task "Check if SKS Keyserver database exists"
      (ansible.builtin.stat 
        (path "/var/lib/sks/DB/key"))
      (register "sks_register_database_pre_build"))
    (task "Configure SKS Keyserver without database"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "etc/sks/sksconf"
          "etc/sks/mailsync"
          "etc/sks/membership"))
      (when "sks_register_database_pre_build is defined and not sks_register_database_pre_build.stat.exists"))
    (task "Build SKS Keyserver database"
      (ansible.builtin.command "/usr/sbin/sks build")
      (become "True")
      (become_user "debian-sks")
      (args 
        (chdir "/var/lib/sks")
        (creates "/var/lib/sks/DB/key"))
      (when "sks_autoinit is defined and sks_autoinit"))
    (task "Check if SKS Keyserver database exists"
      (ansible.builtin.stat 
        (path "/var/lib/sks/DB/key"))
      (register "sks_register_database_post_build"))
    (task "Configure SKS Keyserver with database"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart sks"))
      (with_items (list
          "etc/default/sks"
          "etc/sks/sksconf"
          "etc/sks/mailsync"
          "etc/sks/membership"))
      (when "sks_register_database_post_build is defined and sks_register_database_post_build.stat.exists"))
    (task "Configure frontend webserver"
      (ansible.builtin.include_tasks "sks_frontend.yml")
      (when "sks_frontends is defined and inventory_hostname in sks_frontends"))))
