(playbook "ansible-for-devops/security/main.yml"
    (play
    (hosts "all")
    (become "true")
    (handlers
      (task "restart ssh"
        (service "name=sshd state=restarted")))
    (tasks
      (task "Allow sshd to listen on tcp port 2849."
        (seport 
          (ports "2849")
          (proto "tcp")
          (setype "ssh_port_t")
          (state "present"))
        (when "ansible_selinux.status == 'enabled'"))
      (task "Update SSH configuration to be more secure."
        (lineinfile 
          (dest "/etc/ssh/sshd_config")
          (regexp (jinja "{{ item.regexp }}"))
          (line (jinja "{{ item.line }}"))
          (state "present")
          (validate "sshd -t -f %s"))
        (with_items (list
            
            (regexp "^PasswordAuthentication")
            (line "PasswordAuthentication no")
            
            (regexp "^PermitRootLogin")
            (line "PermitRootLogin no")
            
            (regexp "^Port")
            (line "Port 2849")))
        (notify "restart ssh"))
      (task "Add a deployment user."
        (user 
          (name "johndoe")
          (state "present")))
      (task "Add sudo rights for deployment user."
        (lineinfile 
          (dest "/etc/sudoers")
          (regexp "^johndoe")
          (line "johndoe ALL=(ALL) NOPASSWD: ALL")
          (state "present")
          (validate "visudo -cf %s")))
      (task "Remove unused packages."
        (package 
          (name (list
              "nano"
              "sendmail"))
          (state "absent")))
      (task "Configure the permissions for the messages log."
        (file 
          (path "/var/log/messages")
          (owner "root")
          (group "root")
          (mode "0600")))
      (task "Install dnf-automatic."
        (dnf 
          (name "dnf-automatic")
          (state "present")))
      (task "Ensure dnf-automatic is running and enabled on boot."
        (service 
          (name "dnf-automatic-install.timer")
          (state "started")
          (enabled "yes")))
      (task "Install unattended upgrades package."
        (apt 
          (name "unattended-upgrades")
          (state "present"))
        (when "ansible_os_family == 'Debian'"))
      (task "Copy unattended-upgrades configuration files in place."
        (template 
          (src "../templates/" (jinja "{{ item }}") ".j2")
          (dest "/etc/apt/apt.conf.d/" (jinja "{{ item }}"))
          (owner "root")
          (group "root")
          (mode "0644"))
        (with_items (list
            "20auto-upgrades"
            "50unattended-upgrades"))
        (when "ansible_os_family == 'Debian'"))
      (task "Ensure firewalld is running."
        (service 
          (name "firewalld")
          (state "started")))
      (task "Configure open ports with firewalld."
        (firewalld 
          (state (jinja "{{ item.state }}"))
          (port (jinja "{{ item.port }}"))
          (zone "external")
          (immediate "yes")
          (permanent "yes"))
        (with_items (list
            
            (state "enabled")
            (port "22/tcp")
            
            (state "enabled")
            (port "80/tcp")
            
            (state "enabled")
            (port "123/udp"))))
      (task "Ensure EPEL repo is present."
        (dnf 
          (name "epel-release")
          (state "present"))
        (when "ansible_os_family == 'RedHat'"))
      (task "Install fail2ban (RedHat)."
        (dnf 
          (name "fail2ban")
          (state "present")
          (enablerepo "epel"))
        (when "ansible_os_family == 'RedHat'"))
      (task "Install fail2ban (Debian)."
        (apt 
          (name "fail2ban")
          (state "present"))
        (when "ansible_os_family == 'Debian'"))
      (task "Ensure fail2ban is running and enabled on boot."
        (service 
          (name "fail2ban")
          (state "started")
          (enabled "yes")))
      (task "Install Python SELinux library."
        (dnf 
          (name "python3-libselinux")
          (state "present")))
      (task "Ensure SELinux is enabled in `targeted` mode."
        (selinux 
          (policy "targeted")
          (state "enforcing")))
      (task "Ensure httpd can connect to the network."
        (seboolean 
          (name "httpd_can_network_connect")
          (state "yes")
          (persistent "yes"))
        (when "ansible_selinux.status == 'enabled'")))))
