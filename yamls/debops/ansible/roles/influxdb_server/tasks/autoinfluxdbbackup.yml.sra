(playbook "debops/ansible/roles/influxdb_server/tasks/autoinfluxdbbackup.yml"
  (tasks
    (task "Copy autoinfluxdbbackup script"
      (ansible.builtin.copy 
        (src "usr/sbin/autoinfluxdbbackup")
        (dest "/usr/sbin/autoinfluxdbbackup")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Ensure that the autoinfluxdbbackup directory exists"
      (ansible.builtin.file 
        (path "/etc/autoinfluxdbbackup/")
        (state "directory")
        (owner "root")
        (group "root")
        (mode "0755")))
    (task "Configure autoinfluxdbbackup"
      (ansible.builtin.template 
        (src (jinja "{{ item.template }}") ".j2")
        (dest "/" (jinja "{{ item.template }}"))
        (owner "root")
        (group "root")
        (mode (jinja "{{ item.mode }}")))
      (with_items (list
          
          (template "etc/cron.daily/autoinfluxdbbackup")
          (mode "0755")
          
          (template "etc/default/autoinfluxdbbackup")
          (mode "0644"))))))
