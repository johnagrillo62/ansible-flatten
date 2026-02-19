(playbook "debops/ansible/roles/tzdata/defaults/main.yml"
  (tzdata__enabled "True")
  (tzdata__timezone (jinja "{{ ansible_local.tzdata.timezone | d(\"Etc/UTC\") }}"))
  (tzdata__base_packages (list
      "tzdata"))
  (tzdata__packages (list))
  (tzdata__restart_default_services (list
      "cron.service"
      "rsyslog.service"))
  (tzdata__restart_services (list)))
