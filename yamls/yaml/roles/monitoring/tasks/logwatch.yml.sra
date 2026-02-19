(playbook "yaml/roles/monitoring/tasks/logwatch.yml"
  (tasks
    (task "Install logwatch"
      (apt "pkg=" (jinja "{{ item }}") " state=present")
      (with_items (list
          "libdate-manip-perl"
          "logwatch"))
      (tags (list
          "dependencies")))
    (task "Configure logwatch"
      (template "src=etc_logwatch_conf_logwatch.conf.j2 dest=/etc/logwatch/conf/logwatch.conf"))
    (task "Configure rspamd to let logs through"
      (template "src=etc_rspamd_rspamd.conf.local.j2 dest=/etc/rspamd/rspamd.conf.local")
      (notify "restart rspamd"))
    (task "Remove logwatch's dist cronjob"
      (file "state=absent path=/etc/cron.daily/00logwatch"))
    (task "Configure weekly logwatch cronjob"
      (cron "special_time=weekly job=/usr/sbin/logwatch name=logwatch"))))
