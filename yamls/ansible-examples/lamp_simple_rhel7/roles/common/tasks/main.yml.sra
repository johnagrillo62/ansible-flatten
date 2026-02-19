(playbook "ansible-examples/lamp_simple_rhel7/roles/common/tasks/main.yml"
  (tasks
    (task "Install ntp"
      (yum "name=ntp state=present")
      (tags "ntp"))
    (task "Install common dependencies"
      (yum "name=" (jinja "{{ item }}") " state=installed")
      (with_items (list
          "libselinux-python"
          "libsemanage-python"
          "firewalld")))
    (task "Configure ntp file"
      (template "src=ntp.conf.j2 dest=/etc/ntp.conf")
      (tags "ntp")
      (notify "restart ntp"))
    (task "Start the ntp service"
      (service "name=ntpd state=started enabled=yes")
      (tags "ntp"))))
