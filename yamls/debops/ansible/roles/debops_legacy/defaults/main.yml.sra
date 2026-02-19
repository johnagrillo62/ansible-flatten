(playbook "debops/ansible/roles/debops_legacy/defaults/main.yml"
  (debops_legacy__enabled "True")
  (debops_legacy__remove_default_diversions (list
      
      (name "/etc/redis/redis.conf")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and
                   (ansible_local.redis_server is defined or
                    ansible_local.redis_sentinel is defined))
               else \"ignore\" }}"))
      
      (name "/etc/redis/sentinel.conf")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and
                   (ansible_local.redis_server is defined or
                    ansible_local.redis_sentinel is defined))
               else \"ignore\" }}"))))
  (debops_legacy__remove_diversions (list))
  (debops_legacy__remove_group_diversions (list))
  (debops_legacy__remove_host_diversions (list))
  (debops_legacy__remove_combined_diversions (jinja "{{ debops_legacy__remove_default_diversions
                                               + debops_legacy__remove_diversions
                                               + debops_legacy__remove_group_diversions
                                               + debops_legacy__remove_host_diversions }}"))
  (debops_legacy__remove_default_packages (list))
  (debops_legacy__remove_packages (list))
  (debops_legacy__remove_group_packages (list))
  (debops_legacy__remove_host_packages (list))
  (debops_legacy__remove_combined_packages (jinja "{{ debops_legacy__remove_default_packages
                                             + debops_legacy__remove_packages
                                             + debops_legacy__remove_group_packages
                                             + debops_legacy__remove_host_packages }}"))
  (debops_legacy__remove_default_files (list
      
      (name "/etc/sudoers.d/admins")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and ansible_local.system_groups | d() and
                   (ansible_local.system_groups.configured | d() | bool))
               else \"ignore\" }}"))
      
      (name "/etc/ansible/facts.d/redis.fact")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and
                   (ansible_local.redis_server is defined or
                    ansible_local.redis_sentinel is defined))
               else \"ignore\" }}"))
      
      (name "/etc/redis/notify.d")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and
                   (ansible_local.redis_server is defined or
                    ansible_local.redis_sentinel is defined))
               else \"ignore\" }}"))
      
      (name "/etc/redis/trigger.d")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and
                   (ansible_local.redis_server is defined or
                    ansible_local.redis_sentinel is defined))
               else \"ignore\" }}"))
      
      (name "/usr/local/lib/redis")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and
                   (ansible_local.redis_server is defined or
                    ansible_local.redis_sentinel is defined))
               else \"ignore\" }}"))
      
      (name "/etc/redis/ansible-redis-dynamic.conf")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and
                   (ansible_local.redis_server is defined or
                    ansible_local.redis_sentinel is defined))
               else \"ignore\" }}"))
      
      (name "/etc/redis/ansible-redis-static.conf")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and
                   (ansible_local.redis_server is defined or
                    ansible_local.redis_sentinel is defined))
               else \"ignore\" }}"))
      
      (name "/etc/sysctl.d/30-ferm.conf")
      (state (jinja "{{ \"absent\"
               if (ansible_local | d() and ansible_local.ferm is defined)
               else \"ignore\" }}"))))
  (debops_legacy__remove_files (list))
  (debops_legacy__remove_group_files (list))
  (debops_legacy__remove_host_files (list))
  (debops_legacy__remove_combined_files (jinja "{{ debops_legacy__remove_default_files
                                          + debops_legacy__remove_files
                                          + debops_legacy__remove_group_files
                                          + debops_legacy__remove_host_files }}")))
