(playbook "debops/ansible/roles/global_handlers/handlers/resolvconf.yml"
  (tasks
    (task "Apply static resolvconf configuration"
      (ansible.builtin.command "/usr/local/lib/resolvconf-static")
      (register "global_handlers__resolvconf_register_static_config")
      (changed_when "global_handlers__resolvconf_register_static_config.changed | bool"))
    (task "Refresh /etc/resolv.conf"
      (ansible.builtin.command "resolvconf -u")
      (register "global_handlers__resolvconf_register_refresh")
      (changed_when "global_handlers__resolvconf_register_refresh.changed | bool"))))
