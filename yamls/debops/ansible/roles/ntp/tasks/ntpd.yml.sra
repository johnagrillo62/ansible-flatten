(playbook "debops/ansible/roles/ntp/tasks/ntpd.yml"
  (tasks
    (task "Divert original /etc/ntp.conf"
      (debops.debops.dpkg_divert 
        (path "/etc/ntp.conf"))
      (when "ntp__daemon == 'ntpd'"))
    (task "Configure NTPd"
      (ansible.builtin.template 
        (src "etc/ntpd/ntp.conf.j2")
        (dest "/etc/ntp.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart ntp")))))
