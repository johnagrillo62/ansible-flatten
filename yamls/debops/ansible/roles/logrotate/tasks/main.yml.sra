(playbook "debops/ansible/roles/logrotate/tasks/main.yml"
  (tasks
    (task "Install required packages"
      (ansible.builtin.package 
        (name (jinja "{{ (logrotate__base_packages + logrotate__packages) | flatten }}"))
        (state "present"))
      (register "logrotate__register_packages")
      (until "logrotate__register_packages is succeeded")
      (when "logrotate__enabled | bool"))
    (task "Determine current cron log rotation"
      (ansible.builtin.shell "set -o nounset -o pipefail -o errexit &&
dpkg-divert --list /etc/cron.daily/logrotate | awk '{ print $NF }'
")
      (args 
        (executable "bash"))
      (register "logrotate__register_cron_diversion")
      (changed_when "False")
      (when "logrotate__enabled | bool"))
    (task "Remove previous cron log rotation"
      (debops.debops.dpkg_divert 
        (path "/etc/cron.daily/logrotate")
        (divert (jinja "{{ logrotate__register_cron_diversion.stdout }}"))
        (state "absent")
        (delete "True"))
      (when "(logrotate__enabled | bool and logrotate__register_cron_diversion.stdout | d() and logrotate__register_cron_diversion.stdout | d() != ('/etc/cron.' + logrotate__cron_period + '/logrotate'))"))
    (task "Configure cron log rotation " (jinja "{{ logrotate__cron_period }}")
      (debops.debops.dpkg_divert 
        (path "/etc/cron.daily/logrotate")
        (divert "/etc/cron." (jinja "{{ logrotate__cron_period }}") "/logrotate"))
      (when "(logrotate__enabled | bool and logrotate__cron_period in ['hourly', 'weekly', 'monthly'])"))
    (task "Add/remove diversion of the logrotate config file"
      (debops.debops.dpkg_divert 
        (path "/etc/logrotate.conf")
        (state (jinja "{{ \"present\" if logrotate__enabled | bool else \"absent\" }}"))
        (delete "True")))
    (task "Generate logrotate main configuration file"
      (ansible.builtin.template 
        (src "etc/logrotate.conf.j2")
        (dest "/etc/logrotate.conf")
        (owner "root")
        (group "root")
        (mode "0644"))
      (when "logrotate__enabled | bool"))
    (task "Add/remove diversion of the custom log rotation configuration"
      (debops.debops.dpkg_divert 
        (path "/etc/logrotate.d/" (jinja "{{ item.filename }}"))
        (state (jinja "{{ \"present\"
               if
               (logrotate__enabled | bool and item.state | d(\"present\") != \"absent\")
               else \"absent\" }}"))
        (delete "True"))
      (loop (jinja "{{ logrotate__combined_config | flatten }}"))
      (when "item.filename | d() and item.divert | d(False) | bool"))
    (task "Generate custom log rotation configuration"
      (ansible.builtin.template 
        (src "etc/logrotate.d/config.j2")
        (dest "/etc/logrotate.d/" (jinja "{{ item.filename }}"))
        (owner "root")
        (group "root")
        (mode "0644"))
      (loop (jinja "{{ logrotate__combined_config | flatten }}"))
      (when "(logrotate__enabled | bool and item.filename | d() and item.state | d('present') != 'absent')"))
    (task "Remove custom log rotation configuration"
      (ansible.builtin.file 
        (path "/etc/logrotate.d/" (jinja "{{ item.filename }}"))
        (state "absent"))
      (loop (jinja "{{ logrotate__combined_config | flatten }}"))
      (when "(item.filename | d() and not item.divert | d(False) | bool and (not logrotate__enabled | bool or item.state | d('present') == 'absent'))"))))
