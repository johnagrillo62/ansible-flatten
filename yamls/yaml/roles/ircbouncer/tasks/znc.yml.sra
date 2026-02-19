(playbook "yaml/roles/ircbouncer/tasks/znc.yml"
  (tasks
    (task "Install znc"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "znc"))
      (tags (list
          "dependencies")))
    (task "Create znc group"
      (group "name=znc state=present"))
    (task "Create znc user"
      (user "name=znc state=present home=/usr/lib/znc system=yes group=znc shell=/usr/sbin/nologin"))
    (task "Ensure pid directory exists"
      (file "state=directory path=/var/run/znc group=znc owner=znc"))
    (task "Ensure configuration folders exist"
      (file "state=directory path=/usr/lib/znc/" (jinja "{{ item }}") " group=znc owner=znc")
      (with_items (list
          "moddata"
          "modules"
          "users")))
    (task "Copy znc service file into place"
      (copy "src=etc_systemd_system_znc.service dest=/etc/systemd/system/znc.service mode=0644"))
    (task "Create a combined version of the SSL private key and full certificate chain"
      (shell "cat /etc/letsencrypt/live/" (jinja "{{ domain }}") "/privkey.pem /etc/letsencrypt/live/" (jinja "{{ domain }}") "/fullchain.pem > /usr/lib/znc/znc.pem creates=/usr/lib/znc/znc.pem")
      (notify "restart znc"))
    (task "Update post-certificate-renewal task"
      (template 
        (src "etc_letsencrypt_postrenew_znc.sh.j2")
        (dest "/etc/letsencrypt/postrenew/znc.sh")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Ensure znc user and group can read cert"
      (file "path=/usr/lib/znc/znc.pem group=znc owner=znc mode=0640")
      (notify "restart znc"))
    (task "Check for existing config file"
      (command "cat /usr/lib/znc/configs/znc.conf")
      (register "znc_config")
      (ignore_errors "True")
      (changed_when "False"))
    (task "Create znc config directory"
      (file "state=directory path=/usr/lib/znc/configs group=znc owner=znc"))
    (task "Copy znc configuration file into place"
      (template "src=usr_lib_znc_configs_znc.conf.j2 dest=/usr/lib/znc/configs/znc.conf owner=znc group=znc")
      (when "znc_config.rc != 0")
      (notify "restart znc"))
    (task "Set firewall rule for znc"
      (ufw "rule=allow port=6697 proto=tcp")
      (tags "ufw"))
    (task "Ensure znc is a system service"
      (service "name=znc state=restarted enabled=true"))))
