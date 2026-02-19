(playbook "debops/ansible/roles/auth/tasks/pam_pwhistory.yml"
  (tasks
    (task "Check if password history database exists"
      (ansible.builtin.stat 
        (path "/etc/security/opasswd"))
      (register "auth_register_opasswd"))
    (task "Configure password history database"
      (ansible.builtin.file 
        (path "/etc/security/opasswd")
        (state "touch")
        (owner "root")
        (group "root")
        (mode "0600"))
      (when "auth_register_opasswd is defined and not auth_register_opasswd.stat.exists"))
    (task "Configure pam_pwhistory"
      (ansible.builtin.template 
        (src "usr/share/pam-configs/pwhistory.j2")
        (dest "/usr/share/pam-configs/pwhistory")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Update PAM common configuration")))))
