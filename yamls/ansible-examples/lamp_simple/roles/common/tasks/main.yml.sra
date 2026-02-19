(playbook "ansible-examples/lamp_simple/roles/common/tasks/main.yml"
  (tasks
    (task "Install ntp"
      (yum 
        (name "ntp")
        (state "present"))
      (tags "ntp"))
    (task "Configure ntp file"
      (template 
        (src "ntp.conf.j2")
        (dest "/etc/ntp.conf"))
      (tags "ntp")
      (notify "restart ntp"))
    (task "Start the ntp service"
      (service 
        (name "ntpd")
        (state "started")
        (enabled "yes"))
      (tags "ntp"))
    (task "test to see if selinux is running"
      (command "getenforce")
      (register "sestatus")
      (changed_when "false"))))
