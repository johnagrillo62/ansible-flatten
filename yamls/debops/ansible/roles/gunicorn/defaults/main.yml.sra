(playbook "debops/ansible/roles/gunicorn/defaults/main.yml"
  (gunicorn__binary (jinja "{{ \"gunicorn3\"
                      if (ansible_local | d() and ansible_local.python | d() and
                          (ansible_local.python.installed3 | d()) | bool)
                      else \"gunicorn\" }}"))
  (gunicorn__workers (jinja "{{ ansible_processor_vcpus | int + 1 }}"))
  (gunicorn__user "www-data")
  (gunicorn__group "www-data")
  (gunicorn__systemd_timeout "90")
  (gunicorn__applications (list))
  (gunicorn__dependent_applications (list))
  (gunicorn__logrotate__dependent_config (list
      
      (filename "gunicorn")
      (logs (list
          "/var/log/gunicorn/*.log"))
      (divert "True")
      (options "rotate 4
compress
delaycompress
missingok
notifempty
weekly
sharedscripts
su " (jinja "{{ gunicorn__user }}") " " (jinja "{{ gunicorn__group }}") "
")
      (postrotate "invoke-rc.d --quiet gunicorn reload >/dev/null
")
      (comment "Log rotation for Green Unicorn logs")))
  (gunicorn__python__dependent_packages3 (list
      "gunicorn3"
      "python3-setproctitle"))
  (gunicorn__python__dependent_packages2 (list
      "gunicorn"
      "python-setproctitle")))
