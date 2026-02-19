(playbook "debops/ansible/roles/resolvconf/tasks/main.yml"
  (tasks
    (task "Import custom Ansible plugins"
      (ansible.builtin.import_role 
        (name "ansible_plugins")))
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ q(\"flattened\", (resolvconf__base_packages
                              + resolvconf__packages)) }}"))
        (state (jinja "{{ resolvconf__deploy_state }}")))
      (register "resolvconf__register_packages")
      (until "resolvconf__register_packages is succeeded")
      (when "(resolvconf__enabled | bool and resolvconf__deploy_state in ['present', 'absent'])"))
    (task "Generate static configuration script"
      (ansible.builtin.template 
        (src "usr/local/lib/resolvconf-static.j2")
        (dest "/usr/local/lib/resolvconf-static")
        (mode "0755"))
      (notify (list
          "Apply static resolvconf configuration"))
      (when "(resolvconf__enabled | bool and resolvconf__static_enabled | bool and resolvconf__deploy_state in ['present'])"))
    (task "Create systemd override directory"
      (ansible.builtin.file 
        (path "/etc/systemd/system/resolvconf.service.d")
        (state "directory")
        (mode "0755"))
      (when "(resolvconf__enabled | bool and resolvconf__static_enabled | bool and resolvconf__deploy_state in ['present'])"))
    (task "Generate systemd service override"
      (ansible.builtin.template 
        (src "etc/systemd/system/resolvconf.service.d/static.conf.j2")
        (dest "/etc/systemd/system/resolvconf.service.d/static.conf")
        (mode "0644"))
      (notify (list
          "Reload service manager"))
      (when "(resolvconf__enabled | bool and resolvconf__static_enabled | bool and resolvconf__deploy_state in ['present'])"))
    (task "Add diversion of /etc/resolvconf/interface-order"
      (debops.debops.dpkg_divert 
        (path "/etc/resolvconf/interface-order")
        (state (jinja "{{ resolvconf__deploy_state }}"))
        (delete "True"))
      (notify (list
          "Refresh /etc/resolv.conf"))
      (when "(resolvconf__enabled | bool and resolvconf__deploy_state in ['present'])"))
    (task "Remove diversion of /etc/resolvconf/interface-order"
      (debops.debops.dpkg_divert 
        (path "/etc/resolvconf/interface-order")
        (state (jinja "{{ resolvconf__deploy_state }}"))
        (delete "True"))
      (when "(resolvconf__enabled | bool and resolvconf__deploy_state in ['absent'])"))
    (task "Generate /etc/resolvconf/interface-order configuration"
      (ansible.builtin.template 
        (src "etc/resolvconf/interface-order.j2")
        (dest "/etc/resolvconf/interface-order")
        (mode "0644"))
      (notify (list
          "Refresh /etc/resolv.conf"))
      (when "resolvconf__enabled | bool and resolvconf__deploy_state == 'present'"))
    (task "Remove configuration"
      (ansible.builtin.file 
        (path (jinja "{{ item }}"))
        (state "absent"))
      (when "(resolvconf__enabled | bool and resolvconf__deploy_state in ['absent'])")
      (loop (list
          "/usr/local/lib/resolvconf-static"
          "/etc/systemd/system/resolvconf.service.d/static.conf"
          "/etc/systemd/system/resolvconf.service.d")))
    (task "Create static /etc/resolv.conf"
      (ansible.builtin.copy 
        (mode "0755")
        (dest "/etc/resolv.conf")
        (content (jinja "{{ resolvconf__static_content }}")))
      (when "(resolvconf__enabled | bool and resolvconf__static_enabled | bool and resolvconf__static_content != '' and resolvconf__deploy_state != 'present')"))
    (task "Make sure Ansible fact directory exists"
      (ansible.builtin.file 
        (path "/etc/ansible/facts.d")
        (state "directory")
        (mode "0755")))
    (task "Generate resolvconf Ansible local facts"
      (ansible.builtin.template 
        (src "etc/ansible/facts.d/resolvconf.fact.j2")
        (dest "/etc/ansible/facts.d/resolvconf.fact")
        (mode "0755"))
      (notify (list
          "Refresh host facts"))
      (tags (list
          "meta::facts")))
    (task "Reload facts if they were modified"
      (ansible.builtin.meta "flush_handlers"))))
