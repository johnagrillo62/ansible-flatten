(playbook "debops/ansible/roles/ntp/tasks/systemd-timesyncd.yml"
  (tasks
    (task "Make sure conf override dir exists"
      (ansible.builtin.file 
        (path "/etc/systemd/timesyncd.conf.d")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Configure systemd-timesyncd"
      (ansible.builtin.template 
        (src "etc/systemd/timesyncd.conf.d/ansible.conf.j2")
        (dest "/etc/systemd/timesyncd.conf.d/ansible.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart systemd-timesyncd")))))
