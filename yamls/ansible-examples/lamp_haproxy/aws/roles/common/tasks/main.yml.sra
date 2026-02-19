(playbook "ansible-examples/lamp_haproxy/aws/roles/common/tasks/main.yml"
  (tasks
    (task "Install python bindings for SE Linux"
      (yum 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (list
          "libselinux-python"
          "libsemanage-python")))
    (task "Create the repository for EPEL"
      (copy 
        (src "epel.repo")
        (dest "/etc/yum.repos.d/epel.repo")))
    (task "Create the GPG key for EPEL"
      (copy 
        (src "RPM-GPG-KEY-EPEL-6")
        (dest "/etc/pki/rpm-gpg")))
    (task "install some useful nagios plugins"
      (yum 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (list
          "nagios-nrpe"
          "nagios-plugins-swap"
          "nagios-plugins-users"
          "nagios-plugins-procs"
          "nagios-plugins-load"
          "nagios-plugins-disk")))
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
    (task "insert iptables template"
      (template 
        (src "iptables.j2")
        (dest "/etc/sysconfig/iptables"))
      (when "ansible_distribution_major_version != '7'")
      (notify "restart iptables"))
    (task "test to see if selinux is running"
      (command "getenforce")
      (register "sestatus")
      (changed_when "false"))))
