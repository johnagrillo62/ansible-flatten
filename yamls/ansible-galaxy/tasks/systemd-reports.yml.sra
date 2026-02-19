(playbook "ansible-galaxy/tasks/systemd-reports.yml"
  (tasks
    (task "Manage Paths"
      (block (list
          
          (name "Deploy Galaxy Reports unit")
          (template 
            (owner "root")
            (group "root")
            (mode "0644")
            (src "systemd/galaxy-reports.service.j2")
            (dest "/etc/systemd/system/galaxy-reports.service"))
          (notify "systemd daemon reload")
          
          (name "Enable reports and ensure it is running")
          (systemd 
            (name "galaxy-reports.service")
            (enabled "yes")
            (state "started"))))
      (remote_user (jinja "{{ galaxy_remote_users.root | default(__galaxy_remote_user) }}"))
      (become (jinja "{{ true if galaxy_become_users.root is defined else __galaxy_become }}"))
      (become_user (jinja "{{ galaxy_become_users.root | default(__galaxy_become_user) }}")))))
