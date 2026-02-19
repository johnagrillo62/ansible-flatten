(playbook "yaml/roles/common/tasks/ufw.yml"
  (tasks
    (task "Install ufw"
      (apt "pkg=ufw state=present")
      (tags (list
          "dependencies"
          "ufw")))
    (task "Deny everything"
      (ufw "policy=deny")
      (tags "ufw"))
    (task "Set firewall rule for DNS"
      (ufw "rule=allow port=domain")
      (tags "ufw"))
    (task "Set firewall rule for mosh"
      (ufw "rule=allow port=60000:61000 proto=udp")
      (tags "ufw"))
    (task "Set firewall rules for web traffic and SSH"
      (ufw "rule=allow port=" (jinja "{{ item }}") " proto=tcp")
      (with_items (list
          "http"
          "https"
          "ssh"))
      (tags "ufw"))
    (task "Enable UFW"
      (ufw "state=enabled")
      (tags "ufw"))
    (task "Check config of ufw"
      (command "cat /etc/ufw/ufw.conf")
      (register "ufw_config")
      (changed_when "False")
      (tags "ufw"))))
