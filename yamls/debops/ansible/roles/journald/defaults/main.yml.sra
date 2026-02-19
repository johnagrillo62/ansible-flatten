(playbook "debops/ansible/roles/journald/defaults/main.yml"
  (journald__enabled (jinja "{{ True
                       if (ansible_service_mgr == \"systemd\")
                       else False }}"))
  (journald__version (jinja "{{ ansible_local.journald.version | d(\"0\") }}"))
  (journald__storage "auto")
  (journald__persistent_state (jinja "{{ \"absent\"
                                if (journald__storage == \"none\")
                                else (\"present\"
                                      if (ansible_local.journald.persistent | d()) | bool
                                      else \"absent\") }}"))
  (journald__fss_enabled (jinja "{{ True
                           if (journald__persistent_state == \"present\")
                           else False }}"))
  (journald__fss_interval "15min")
  (journald__fss_verify_key_path (jinja "{{ \"journald/fss/\" + inventory_hostname + \"/verify_key\" }}"))
  (journald__fss_verify_key (jinja "{{ lookup(\"file\", secret + \"/\" + journald__fss_verify_key_path) }}"))
  (journald__default_configuration (list
      
      (name "Storage")
      (value (jinja "{{ journald__storage }}"))
      (state (jinja "{{ \"init\"
               if (journald__storage == \"auto\")
               else \"present\" }}"))
      
      (name "Compress")
      (value "True")
      (state "init")
      
      (name "Seal")
      (value (jinja "{{ journald__fss_enabled }}"))
      (state (jinja "{{ \"init\" if journald__fss_enabled | bool else \"present\" }}"))
      
      (name "SplitMode")
      (value "uid")
      (state "init")
      
      (name "SyncIntervalSec")
      (value "5m")
      (state "init")
      
      (name "RateLimitIntervalSec")
      (value "30s")
      (state "init")
      
      (name "RateLimitBurst")
      (value "10000")
      (state "init")
      
      (name "SystemMaxUse")
      (value "")
      (state "init")
      
      (name "SystemKeepFree")
      (value "")
      (state "init")
      
      (name "SystemMaxFileSize")
      (value "")
      (state "init")
      
      (name "SystemMaxFiles")
      (value "100")
      (state "init")
      
      (name "RuntimeMaxUse")
      (value "")
      (state "init")
      
      (name "RuntimeKeepFree")
      (value "")
      (state "init")
      
      (name "RuntimeMaxFileSize")
      (value "")
      (state "init")
      
      (name "RuntimeMaxFiles")
      (value "100")
      (state "init")
      
      (name "MaxRetentionSec")
      (value "")
      (state "init")
      
      (name "MaxFileSec")
      (value "1month")
      (state "init")
      
      (name "ForwardToSyslog")
      (value "True")
      (state "init")
      
      (name "ForwardToKMsg")
      (value "False")
      (state "init")
      
      (name "ForwardToConsole")
      (value "False")
      (state "init")
      
      (name "ForwardToWall")
      (value "True")
      (state "init")
      
      (name "TTYPath")
      (value "/dev/console")
      (state "init")
      
      (name "MaxLevelStore")
      (value "debug")
      (state "init")
      
      (name "MaxLevelSyslog")
      (value "debug")
      (state "init")
      
      (name "MaxLevelKMsg")
      (value "notice")
      (state "init")
      
      (name "MaxLevelConsole")
      (value "info")
      (state "init")
      
      (name "MaxLevelWall")
      (value "emerg")
      (state "init")
      
      (name "LineMax")
      (value "48K")
      (state "init")
      
      (name "ReadKMsg")
      (value "True")
      (state "init")))
  (journald__configuration (list))
  (journald__group_configuration (list))
  (journald__host_configuration (list))
  (journald__combined_configuration (jinja "{{ journald__default_configuration
                                      + journald__configuration
                                      + journald__group_configuration
                                      + journald__host_configuration }}")))
