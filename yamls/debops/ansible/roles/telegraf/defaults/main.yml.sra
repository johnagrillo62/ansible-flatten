(playbook "debops/ansible/roles/telegraf/defaults/main.yml"
  (telegraf__base_packages (list
      "telegraf"))
  (telegraf__packages (list))
  (telegraf__additional_groups (list
      (jinja "{{ (ansible_local.proc_hidepid.group | d(\"procadmins\"))
        if (ansible_local.proc_hidepid.enabled | d()) | bool
        else [] }}")))
  (telegraf__default_configuration (list
      
      (name "agent")
      (config 
        (agent 
          (interval "10s")
          (round_interval "True")
          (metric_batch_size "1000")
          (metric_buffer_limit "10000")
          (collection_jitter "0s")
          (flush_interval "10s")
          (flush_jitter "0s")
          (precision "")
          (hostname "")
          (omit_hostname "False")))))
  (telegraf__configuration (list))
  (telegraf__group_configuration (list))
  (telegraf__host_configuration (list))
  (telegraf__combined_configuration (jinja "{{ telegraf__default_configuration
                                      + telegraf__configuration
                                      + telegraf__group_configuration
                                      + telegraf__host_configuration }}"))
  (telegraf__default_plugins (list
      
      (name "input_system")
      (config 
        (inputs 
          (kernel )
          (mem )
          (processes )
          (swap )
          (system )))
      
      (name "input_cpu")
      (config 
        (inputs 
          (cpu (list
              
              (percpu "True")
              (totalcpu "True")
              (collect_cpu_time "False")
              (report_active "False")))))
      
      (name "input_disk")
      (config 
        (inputs 
          (disk (list
              
              (ignore_fs (list
                  "tmpfs"
                  "devtmpfs"
                  "devfs"
                  "iso8660"
                  "ovelay"
                  "aufs"
                  "squashfs"))))))
      
      (name "input_diskio")
      (config 
        (inputs 
          (diskio )))
      
      (name "input_internal")
      (config 
        (inputs 
          (internal )))
      
      (name "input_influxdb_local")
      (config 
        (inputs 
          (influxdb_v2_listener 
            (service_address "127.0.0.1:38086"))))
      (state "present")
      
      (name "output_discard")
      (config 
        (outputs 
          (discard )))
      (state "present")))
  (telegraf__plugins (list))
  (telegraf__group_plugins (list))
  (telegraf__host_plugins (list))
  (telegraf__combined_plugins (jinja "{{ telegraf__default_plugins
                                + telegraf__plugins
                                + telegraf__group_plugins
                                + telegraf__host_plugins }}"))
  (telegraf__influxdata__dependent_packages (list
      (jinja "{{ telegraf__base_packages }}")
      (jinja "{{ telegraf__packages }}"))))
