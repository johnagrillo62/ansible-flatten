(playbook "ansible-examples/wordpress-nginx/roles/common/tasks/main.yml"
  (tasks
    (task "Install libselinux-python"
      (yum "name=libselinux-python state=present"))
    (task "Reload ansible_facts"
      (setup null))
    (task "Copy the EPEL repository definition"
      (copy "src=epel.repo dest=/etc/yum.repos.d/epel.repo"))
    (task "Create the GPG key for EPEL"
      (copy "src=RPM-GPG-KEY-EPEL-6 dest=/etc/pki/rpm-gpg"))
    (task "Set up iptables rules"
      (copy "src=iptables-save dest=/etc/sysconfig/iptables")
      (notify "restart iptables"))))
