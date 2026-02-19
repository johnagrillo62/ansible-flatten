(playbook "debops/ansible/roles/ntp/tasks/chrony.yml"
  (tasks
    (task "Configure chrony"
      (ansible.builtin.template 
        (src "etc/chrony/chrony.conf.j2")
        (dest "/etc/chrony/chrony.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (notify (list
          "Restart chrony")))))
