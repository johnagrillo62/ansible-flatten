(playbook "ansible-examples/jboss-standalone/roles/jboss-standalone/tasks/main.yml"
  (tasks
    (task "Install Java 1.7 and some basic dependencies"
      (yum 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (list
          "unzip"
          "java-1.7.0-openjdk"
          "libselinux-python"
          "libsemanage-python")))
    (task "Download JBoss from jboss.org"
      (get_url 
        (url "http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.zip")
        (dest "/opt/jboss-as-7.1.1.Final.zip")))
    (task "Extract archive"
      (unarchive 
        (dest "/usr/share")
        (src "/opt/jboss-as-7.1.1.Final.zip")
        (creates "/usr/share/jboss-as")
        (copy "no")))
    (task "Rename install directory"
      (command "/bin/mv jboss-as-7.1.1.Final jboss-as")
      (args 
        (chdir "/usr/share")
        (creates "/usr/share/jboss-as")))
    (task "Copying standalone.xml configuration file"
      (template 
        (src "standalone.xml")
        (dest "/usr/share/jboss-as/standalone/configuration/"))
      (notify "restart jboss"))
    (task "Add group \"jboss\""
      (group 
        (name "jboss")))
    (task "Add user \"jboss\""
      (user 
        (name "jboss")
        (group "jboss")
        (home "/usr/share/jboss-as")))
    (task "Change ownership of JBoss installation"
      (file 
        (path "/usr/share/jboss-as/")
        (owner "jboss")
        (group "jboss")
        (state "directory")
        (recurse "yes")))
    (task "Copy the init script"
      (copy 
        (src "jboss-as-standalone.sh")
        (dest "/etc/init.d/jboss")
        (mode "0755")))
    (task "Workaround for systemd bug"
      (shell "service jboss start && chkconfig jboss on")
      (ignore_errors "yes"))
    (task "Enable JBoss to be started at boot"
      (service 
        (name "jboss")
        (enabled "yes")
        (state "started")))
    (task "deploy iptables rules"
      (template 
        (src "iptables-save")
        (dest "/etc/sysconfig/iptables"))
      (when "ansible_distribution_major_version != \"7\"")
      (notify "restart iptables"))
    (task "Ensure that firewalld is installed"
      (yum 
        (name "firewalld")
        (state "present"))
      (when "ansible_distribution_major_version == \"7\""))
    (task "Ensure that firewalld is started"
      (service 
        (name "firewalld")
        (state "started"))
      (when "ansible_distribution_major_version == \"7\""))
    (task "deploy firewalld rules"
      (firewalld 
        (immediate "yes")
        (port (jinja "{{ item }}"))
        (state "enabled")
        (permanent "yes"))
      (when "ansible_distribution_major_version == \"7\"")
      (with_items (list
          (jinja "{{ http_port }}") "/tcp"
          (jinja "{{ https_port }}") "/tcp")))))
