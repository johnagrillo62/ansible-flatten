(playbook "debops/ansible/roles/nscd/defaults/main.yml"
  (nscd__flavor "unscd")
  (nscd__base_packages (list
      (jinja "{{ nscd__flavor }}")))
  (nscd__packages (list))
  (nscd__default_configuration (list
      
      (name "global")
      (options (list
          
          (name "logfile")
          (value "/var/log/nscd.log")
          (state "comment")
          
          (name "threads")
          (value "4")
          (state "comment")
          
          (name "max_threads")
          (value "32")
          (state "comment")
          
          (name "server_user")
          (value (jinja "{{ \"unscd\"
                   if (nscd__flavor == \"unscd\")
                   else \"nobody\" }}"))
          (state (jinja "{{ \"present\"
                   if (nscd__flavor == \"unscd\")
                   else \"comment\" }}"))
          
          (name "stat_user")
          (value "somebody")
          (state "comment")
          
          (name "debug_level")
          (value "0")
          
          (name "reload_count")
          (value "5")
          (state "comment")
          
          (name "paranoia")
          (value "False")
          
          (name "restart_interval")
          (value "3600")
          (state "comment")))
      
      (name "passwd")
      (enable_cache "True")
      (positive_time_to_live "600")
      (negative_time_to_live "20")
      (suggested_size "1001")
      (check_files "True")
      (persistent "True")
      (shared "True")
      (max_db_size "33554432")
      (auto_propagate "True")
      
      (name "group")
      (enable_cache "True")
      (positive_time_to_live "3600")
      (negative_time_to_live "60")
      (suggested_size "1001")
      (check_files "True")
      (persistent "True")
      (shared "True")
      (max_db_size "33554432")
      (auto_propagate "True")
      
      (name "hosts")
      (comment "hosts caching is broken with gethostby* calls, hence is now disabled
by default. Specifically, the caching does not obey DNS TTLs, and
thus could lead to problems if the positive-time-to-live is
significantly larger than the actual TTL.

You should really use a caching nameserver instead of nscd for this
sort of request. However, you can easily re-enable this by default.
")
      (enable_cache "False")
      (positive_time_to_live "3600")
      (negative_time_to_live "20")
      (suggested_size "1001")
      (check_files "True")
      (persistent "True")
      (shared "True")
      (max_db_size "33554432")
      (state "comment")
      
      (name "services")
      (enable_cache "True")
      (positive_time_to_live "28800")
      (negative_time_to_live "20")
      (suggested_size "1001")
      (check_files "True")
      (persistent "True")
      (shared "True")
      (max_db_size "33554432")
      (state (jinja "{{ \"absent\"
               if (nscd__flavor == \"unscd\")
               else \"present\" }}"))
      
      (name "netgroup")
      (enable_cache "True")
      (positive_time_to_live "28800")
      (negative_time_to_live "20")
      (suggested_size "1001")
      (check_files "True")
      (persistent "True")
      (shared "True")
      (max_db_size "33554432")
      (state (jinja "{{ \"absent\"
               if (nscd__flavor == \"unscd\")
               else \"present\" }}"))))
  (nscd__configuration (list))
  (nscd__group_configuration (list))
  (nscd__host_configuration (list))
  (nscd__combined_configuration (jinja "{{ nscd__default_configuration
                                  + nscd__configuration
                                  + nscd__group_configuration
                                  + nscd__host_configuration }}")))
