(playbook "debops/ansible/roles/smstools/tasks/main.yml"
  (tasks
    (task "Import DebOps global handlers"
      (ansible.builtin.import_role 
        (name "global_handlers")))
    (task "Install SMS Tools packages"
      (ansible.builtin.package 
        (name (jinja "{{ item }}"))
        (state "present"))
      (with_items (list
          "smstools"
          "xinetd"
          "libconfig-tiny-perl"))
      (register "smstools__register_packages")
      (until "smstools__register_packages is succeeded"))
    (task "Check current smsd home directory"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit && getent passwd smsd | grep \"/home/smsd\" || true")
      (args 
        (executable "bash"))
      (register "smstools_register_home")
      (changed_when "False"))
    (task "Stop smsd for home directory change"
      (ansible.builtin.service 
        (name "smstools")
        (state "stopped"))
      (when "smstools_register_home is defined and smstools_register_home.stdout | d()"))
    (task "Fix smsd home directory"
      (ansible.builtin.user 
        (name "smsd")
        (home "/var/spool/sms"))
      (when "smstools_register_home is defined and smstools_register_home.stdout | d()"))
    (task "Start smsd with new home directory"
      (ansible.builtin.service 
        (name "smstools")
        (state "started"))
      (when "smstools_register_home is defined and smstools_register_home.stdout | d()"))
    (task "Configure smsd"
      (ansible.builtin.template 
        (src "etc/smsd.conf.j2")
        (dest "/etc/smsd.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart smstools")))
    (task "Make sure /srv/users home directory exists"
      (ansible.builtin.file 
        (dest "/srv/users")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0751")))
    (task "Create SMS service system group"
      (ansible.builtin.group 
        (name (jinja "{{ smstools_service_group }}"))
        (system "True")
        (state "present")))
    (task "Create SMS service system user"
      (ansible.builtin.user 
        (name (jinja "{{ smstools_service_user }}"))
        (group (jinja "{{ smstools_service_group }}"))
        (system "True")
        (home (jinja "{{ smstools_service_home }}"))
        (state "present")
        (shell "/bin/false")))
    (task "Create directory for SMS service scripts"
      (ansible.builtin.file 
        (dest "/usr/local/lib/smstools")
        (state "directory")
        (owner "root")
        (group "staff")
        (mode "0755")))
    (task "Install smsd scripts"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "smsd")
        (group "sms")
        (mode "0750"))
      (with_items (list
          "usr/local/bin/sendsms"
          "usr/local/lib/smstools/sms-service"
          "usr/local/lib/smstools/sms-transport"
          "usr/local/lib/smstools/test-sms-on-reboot")))
    (task "Install root scripts"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0750"))
      (with_items (list
          "usr/local/lib/smstools/fix-device-permissions")))
    (task "Install Postfix configuration files"
      (ansible.builtin.template 
        (src "usr/local/lib/smstools/" (jinja "{{ item }}") ".j2")
        (dest "/usr/local/lib/smstools/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "postfix_recipient_canonical_map"
          "postfix_transport"
          "postfix_relay_recipient_map"
          "postfix_virtual_alias_map"))
      (notify (list
          "Reload postfix")))
    (task "Configure access to sendsms via sudo"
      (ansible.builtin.template 
        (src "etc/sudoers.d/smstools.j2")
        (dest "/etc/sudoers.d/smstools")
        (owner "root")
        (group "root")
        (mode "0440"))
      (when "(ansible_local | d() and ansible_local.sudo | d() and (ansible_local.sudo.installed | d()) | bool)"))
    (task "Configure xinetd SMS service"
      (ansible.builtin.template 
        (src "etc/xinetd.d/sms.j2")
        (dest "/etc/xinetd.d/sms")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Reload xinetd")))
    (task "Configure mail to SMS transport"
      (ansible.builtin.template 
        (src (jinja "{{ item }}") ".j2")
        (dest "/" (jinja "{{ item }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (with_items (list
          "etc/sms-senders"
          "etc/sms-msgdel"
          "etc/sms-transport.conf")))
    (task "Fix device permissions on boot in OpenVZ containers"
      (ansible.builtin.lineinfile 
        (dest "/etc/rc.local")
        (state "present")
        (insertbefore "^exit 0")
        (regexp "^/usr/local/lib/smstools/fix-device-permissions")
        (line "/usr/local/lib/smstools/fix-device-permissions")
        (mode "0755"))
      (register "smstools_register_fixpermissions")
      (when "(ansible_virtualization_type is defined and ansible_virtualization_type == 'openvz') and (ansible_virtualization_role is defined and ansible_virtualization_role == 'guest')"))
    (task "Fix permissions manually if installed"
      (ansible.builtin.command "/usr/local/lib/smstools/fix-device-permissions")
      (register "smstools__register_fix_perms")
      (changed_when "smstools__register_fix_perms.changed | bool")
      (when "smstools_register_fixpermissions is defined and smstools_register_fixpermissions is changed"))
    (task "Configure SMS gateway test on reboot"
      (ansible.builtin.cron 
        (name "SMS gateway test on reboot")
        (user (jinja "{{ smstools_service_user }}"))
        (job "/usr/local/lib/smstools/test-sms-on-reboot")
        (special_time "reboot")
        (state "present"))
      (when "(smstools_test_recipients is defined and smstools_test_recipients)"))
    (task "Check if rsyslog is installed"
      (ansible.builtin.stat 
        (path "/etc/rsyslog.d"))
      (register "smstools_register_rsyslog"))
    (task "Configure syslog"
      (ansible.builtin.template 
        (src "etc/rsyslog.d/smstools.conf.j2")
        (dest "/etc/rsyslog.d/smstools.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart rsyslogd"))
      (when "(smstools_register_rsyslog is defined and smstools_register_rsyslog) and smstools_register_rsyslog.stat.exists"))
    (task "Configure logrotate"
      (ansible.builtin.template 
        (src "etc/logrotate.d/sms.j2")
        (dest "/etc/logrotate.d/sms")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "(smstools_register_rsyslog is defined and smstools_register_rsyslog) and smstools_register_rsyslog.stat.exists"))))
