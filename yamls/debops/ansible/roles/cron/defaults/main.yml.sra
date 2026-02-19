(playbook "debops/ansible/roles/cron/defaults/main.yml"
  (cron__enabled "True")
  (cron__base_packages (list
      "cron"))
  (cron__packages (list))
  (cron__crontab_deploy_state "present")
  (cron__crontab_seed (jinja "{{ inventory_hostname }}"))
  (cron__crontab_offset_seeds (jinja "{{ ansible_local.cron.crontab_offset_seeds
                                if (ansible_local.cron.crontab_offset_seeds | d())
                                else ((ansible_all_ipv4_addresses
                                       + ansible_all_ipv6_addresses
                                       + (ansible_default_ipv4.values() | d([])) | list
                                       + [ansible_machine_id | d(), ansible_memtotal_mb]
                                       + [ansible_product_name, ansible_product_version]
                                       + [ansible_kernel])
                                      | map(\"regex_replace\", \"^(.*)$\",
                                            (ansible_date_time.epoch | string + \"\\1\"))
                                      | map(\"hash\", \"sha256\") | list | unique) }}"))
  (cron__crontab_hours (list
      "0"
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "18"
      "19"
      "20"
      "21"
      "22"
      "23"))
  (cron__crontab_weekday_days (list
      "6"
      "7"))
  (cron__crontab_day_ranges (list
      "1"
      "7"))
  (cron__crontab_default_environment 
    (SHELL "/bin/sh")
    (PATH "/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"))
  (cron__crontab_environment )
  (cron__crontab_group_environment )
  (cron__crontab_host_environment )
  (cron__crontab_combined_environment (jinja "{{ cron__crontab_default_environment
                                        | combine(cron__crontab_environment,
                                                  cron__crontab_group_environment,
                                                  cron__crontab_host_environment) }}"))
  (cron__crontab_default_jobs (list
      
      (name "crontab-hourly")
      (minute (jinja "{{ 59 | random(seed=(cron__crontab_seed
                                  + (cron__crontab_offset_seeds
                                     | random(seed=cron__crontab_offset_seeds[0])))) }}"))
      (user "root")
      (job "cd / && run-parts --report /etc/cron.hourly")
      
      (name "crontab-daily")
      (minute (jinja "{{ 59 | random(seed=(cron__crontab_seed
                                  + (cron__crontab_offset_seeds
                                     | random(seed=cron__crontab_offset_seeds[1])))) }}"))
      (hour (jinja "{{ cron__crontab_hours | random(seed=(cron__crontab_seed
                                                 + (cron__crontab_offset_seeds
                                                    | random(seed=cron__crontab_offset_seeds[2])))) }}"))
      (user "root")
      (job "test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )")
      
      (name "crontab-weekly")
      (minute (jinja "{{ 59 | random(seed=(cron__crontab_seed
                                  + (cron__crontab_offset_seeds
                                     | random(seed=cron__crontab_offset_seeds[3])))) }}"))
      (hour (jinja "{{ cron__crontab_hours | random(seed=(cron__crontab_seed
                                                 + (cron__crontab_offset_seeds
                                                    | random(seed=cron__crontab_offset_seeds[4])))) }}"))
      (weekday (jinja "{{ cron__crontab_weekday_days
                 | random(seed=(cron__crontab_seed
                                + (cron__crontab_offset_seeds
                                   | random(seed=cron__crontab_offset_seeds[5])))) }}"))
      (user "root")
      (job "test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )")
      
      (name "crontab-monthly")
      (minute (jinja "{{ 59 | random(seed=(cron__crontab_seed
                                  + (cron__crontab_offset_seeds
                                     | random(seed=cron__crontab_offset_seeds[6])))) }}"))
      (hour (jinja "{{ cron__crontab_hours | random(seed=(cron__crontab_seed
                                                 + (cron__crontab_offset_seeds
                                                    | random(seed=cron__crontab_offset_seeds[7])))) }}"))
      (day (jinja "{{ cron__crontab_day_ranges[1]
             | random(start=cron__crontab_day_ranges[0],
                      seed=(cron__crontab_seed
                            + (cron__crontab_offset_seeds
                               | random(seed=cron__crontab_offset_seeds[8])))) }}"))
      (user "root")
      (job "test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )")))
  (cron__crontab_jobs (list))
  (cron__crontab_group_jobs (list))
  (cron__crontab_host_jobs (list))
  (cron__crontab_combined_jobs (jinja "{{ cron__crontab_default_jobs
                                 + cron__crontab_jobs
                                 + cron__crontab_group_jobs
                                 + cron__crontab_host_jobs }}"))
  (cron__default_jobs )
  (cron__dependent_jobs )
  (cron__jobs )
  (cron__group_jobs )
  (cron__host_jobs )
  (cron__combined_jobs (jinja "{{ lookup(\"template\",
                         \"lookup/cron__combined_jobs.j2\",
                         convert_data=False) | from_yaml }}")))
