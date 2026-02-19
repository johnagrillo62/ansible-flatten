(playbook "yaml/roles/common/tasks/ntp.yml"
  (tasks
    (task "Install ntp"
      (apt "pkg=ntp state=present")
      (tags (list
          "dependencies")))
    (task "Configure ntp"
      (template "src=ntp.conf.j2 dest=/etc/ntp.conf")
      (notify (list
          "restart ntp")))
    (task "Ensure ntpd is running"
      (service "name=ntp state=started"))
    (task "Ensure ntp is enabled"
      (command "update-rc.d ntp enable creates=/etc/rc3.d/S03ntp"))))
