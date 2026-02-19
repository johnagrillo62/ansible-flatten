(playbook "debops/ansible/roles/atd/defaults/main.yml"
  (atd_enabled "True")
  (atd_default_allow (list
      (jinja "{{ (ansible_user
                          if (ansible_user | d() and
                              ansible_user != \"root\")
                          else lookup(\"env\", \"USER\")) }}")))
  (atd_allow (list))
  (atd_group_allow (list))
  (atd_host_allow (list))
  (atd_default_deny (list))
  (atd_deny (list))
  (atd_batch_base (jinja "{{ ansible_processor_vcpus }}"))
  (atd_multiplier_min "80")
  (atd_multiplier_max "100")
  (atd_batch_multiplier (jinja "{{ ((atd_multiplier_max | int |
                            random(atd_multiplier_min | int)) / 100) }}"))
  (atd_batch_load (jinja "{{ (ansible_local.atd.batch_load
                     if (ansible_local.atd.batch_load | d())
                     else ((atd_batch_base | float) *
                           (atd_batch_multiplier | float))) }}"))
  (atd_interval_min "30")
  (atd_interval_max "120")
  (atd_batch_interval (jinja "{{ (ansible_local.atd.batch_interval
                         if (ansible_local.atd.batch_interval | d())
                         else (atd_interval_max | int |
                               random(atd_interval_min | int))) }}")))
