(playbook "debops/ansible/roles/global_handlers/handlers/fail2ban.yml"
  (tasks
    (task "Assemble /etc/fail2ban/jail.local"
      (ansible.builtin.assemble 
        (src "/etc/fail2ban/jail.local.d")
        (dest "/etc/fail2ban/jail.local")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload fail2ban jails")))
    (task "Restart fail2ban"
      (ansible.builtin.service 
        (name "fail2ban")
        (state "restarted")))
    (task "Reload fail2ban jails"
      (ansible.builtin.shell "type fail2ban-server > /dev/null && (fail2ban-client ping > /dev/null && fail2ban-client reload > /dev/null || true) || true")
      (register "global_handlers__fail2ban_register_reload")
      (changed_when "global_handlers__fail2ban_register_reload.changed | bool"))))
