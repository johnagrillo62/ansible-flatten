(playbook "yaml/roles/monitoring/tasks/collectd.yml"
  (tasks
    (task "Install collectd"
      (apt "pkg=collectd state=present")
      (tags (list
          "dependencies")))
    (task "Copy collectd configuration file into place"
      (template "src=etc_collectd_collectd.conf.j2 dest=/etc/collectd/collectd.conf")
      (notify "restart collectd"))
    (task "Ensure collectd is started"
      (service "name=collectd state=started"))
    (task "Ensure collectd is enabled"
      (command "update-rc.d collectd enable creates=/etc/rc3.d/S03collectd"))))
