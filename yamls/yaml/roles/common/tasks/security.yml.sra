(playbook "yaml/roles/common/tasks/security.yml"
  (tasks
    (task "Install security-related packages"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "fail2ban"
          "whois"
          "lynis"
          "rkhunter"))
      (tags (list
          "dependencies")))
    (task "Copy fail2ban configuration into place"
      (template "src=etc_fail2ban_jail.local.j2 dest=/etc/fail2ban/jail.local")
      (notify "restart fail2ban"))
    (task "Copy fail2ban dovecot configuration into place"
      (copy "src=etc_fail2ban_filter.d_dovecot-pop3imap.conf dest=/etc/fail2ban/filter.d/dovecot-pop3imap.conf")
      (notify "restart fail2ban"))
    (task "Ensure fail2ban is started"
      (service "name=fail2ban state=started"))
    (task "Update sshd config for PFS and more secure defaults"
      (template "src=etc_ssh_sshd_config.j2 dest=/etc/ssh/sshd_config")
      (notify "restart ssh"))
    (task "Update ssh config for more secure defaults"
      (template "src=etc_ssh_ssh_config.j2 dest=/etc/ssh/ssh_config"))))
