(playbook "debops/ansible/roles/logrotate/defaults/main.yml"
  (logrotate__enabled "True")
  (logrotate__base_packages (list
      "logrotate"))
  (logrotate__packages (list))
  (logrotate__cron_period "daily")
  (logrotate__default_period "weekly")
  (logrotate__default_rotation "4")
  (logrotate__options "")
  (logrotate__group_options "")
  (logrotate__host_options "")
  (logrotate__default_options "create
" (jinja "{{ logrotate__default_period }}") "
rotate " (jinja "{{ logrotate__default_rotation }}") "
tabooext + .dpkg-divert
include /etc/logrotate.d
")
  (logrotate__default_config (list
      
      (log "/var/log/wtmp")
      (comment "No packages own wtmp or btmp, they will be managed directly")
      (options "missingok
monthly
create 0664 root utmp
rotate 1
")
      (state (jinja "{{ \"present\"
               if (ansible_distribution_release in
                   ([\"stretch\", \"trusty\", \"xenial\", \"bionic\"]))
               else \"absent\" }}"))
      
      (log "/var/log/btmp")
      (options "missingok
monthly
create 0660 root utmp
rotate 1
")
      (state (jinja "{{ \"present\"
               if (ansible_distribution_release in
                   ([\"stretch\", \"trusty\", \"xenial\", \"bionic\"]))
               else \"absent\" }}"))))
  (logrotate__config (list))
  (logrotate__group_config (list))
  (logrotate__host_config (list))
  (logrotate__dependent_config (list))
  (logrotate__combined_config (jinja "{{ logrotate__config
                                + logrotate__group_config
                                + logrotate__host_config
                                + logrotate__dependent_config }}")))
