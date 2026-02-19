(playbook "ansible-examples/wordpress-nginx_rhel7/roles/common/tasks/main.yml"
  (tasks
    (task "Copy the NGINX repository definition"
      (copy "src=nginx.repo dest=/etc/yum.repos.d/"))
    (task "Copy the EPEL repository definition"
      (copy "src=epel.repo dest=/etc/yum.repos.d/"))
    (task "Copy the REMI repository definition"
      (copy "src=remi.repo dest=/etc/yum.repos.d/"))
    (task "Create the GPG key for NGINX"
      (copy "src=RPM-GPG-KEY-NGINX dest=/etc/pki/rpm-gpg"))
    (task "Create the GPG key for EPEL"
      (copy "src=RPM-GPG-KEY-EPEL-7 dest=/etc/pki/rpm-gpg"))
    (task "Create the GPG key for REMI"
      (copy "src=RPM-GPG-KEY-remi dest=/etc/pki/rpm-gpg"))
    (task "Install Firewalld"
      (yum "name=firewalld state=present"))
    (task "Firewalld service state"
      (service "name=firewalld state=started enabled=yes"))))
